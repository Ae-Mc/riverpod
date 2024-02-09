import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_analyzer_utils/riverpod_analyzer_utils.dart';

// ignore: implementation_imports, safe as we are the one controlling this file
import 'package:riverpod_annotation/src/riverpod_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'models.dart';
import 'parse_generator.dart';
import 'templates/family.dart';
import 'templates/hash.dart';
import 'templates/notifier.dart';
import 'templates/parameters.dart';
import 'templates/provider.dart';
import 'templates/provider_variable.dart';
import 'templates/ref.dart';
import 'type.dart';

const riverpodTypeChecker = TypeChecker.fromRuntime(Riverpod);

String providerDocFor(Element element) {
  return element.documentationComment == null
      ? '/// See also [${element.name}].'
      : '${element.documentationComment}\n///\n/// Copied from [${element.name}].';
}

String metaAnnotations(NodeList<Annotation> metadata) {
  final buffer = StringBuffer();
  for (final annotation in metadata) {
    final element = annotation.elementAnnotation;
    if (element == null) continue;
    if (element.isDeprecated ||
        element.isVisibleForTesting ||
        element.isProtected) {
      buffer.writeln('$annotation');
      continue;
    }
  }

  return buffer.toString();
}

const _defaultProviderNameSuffix = 'Provider';

/// May be thrown by generators during [Generator.generate].
class RiverpodInvalidGenerationSourceError
    extends InvalidGenerationSourceError {
  RiverpodInvalidGenerationSourceError(
    super.message, {
    super.todo = '',
    super.element,
    this.astNode,
  });

  final AstNode? astNode;

// TODO override toString to render AST nodes.
}

@immutable
class RiverpodGenerator extends ParserGenerator<Riverpod> {
  RiverpodGenerator(Map<String, Object?> mapConfig)
      : options = BuildYamlOptions.fromMap(mapConfig);

  final BuildYamlOptions options;

  @override
  String generateForUnit(List<CompilationUnit> compilationUnits) {
    final riverpodResult = ResolvedRiverpodLibraryResult.from(compilationUnits);
    return runGenerator(riverpodResult);
  }

  String runGenerator(ResolvedRiverpodLibraryResult riverpodResult) {
    for (final error in riverpodResult.errors) {
      throw RiverpodInvalidGenerationSourceError(
        error.message,
        element: error.targetElement,
        astNode: error.targetNode,
      );
    }

    final buffer = StringBuffer();

    riverpodResult.visitChildren(_RiverpodGeneratorVisitor(buffer, options));

    // Only emit the header if we actually generated something
    if (buffer.isNotEmpty) {
      buffer.writeln(
        r"const $kDebugMode = bool.fromEnvironment('dart.vm.product');",
      );

      buffer.write('''
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use_from_same_package
''');
    }

    return buffer.toString();
  }
}

class _RiverpodGeneratorVisitor extends RecursiveRiverpodAstVisitor {
  _RiverpodGeneratorVisitor(this.buffer, this.options);

  final StringBuffer buffer;
  final BuildYamlOptions options;

  String get suffix => options.providerNameSuffix ?? _defaultProviderNameSuffix;

  String get familySuffix => options.providerFamilyNameSuffix ?? suffix;

  void visitGeneratorProviderDeclaration(
    GeneratorProviderDeclaration provider,
  ) {
    final allTransitiveDependencies =
        _computeAllTransitiveDependencies(provider);

    ProviderVariableTemplate(provider, options).run(buffer);
    ProviderTemplate(
      provider,
      options,
      allTransitiveDependencies: allTransitiveDependencies,
    ).run(buffer);
    HashFnTemplate(provider).run(buffer);
    FamilyTemplate(
      provider,
      options,
      allTransitiveDependencies: allTransitiveDependencies,
    ).run(buffer);
  }

  List<String>? _computeAllTransitiveDependencies(
    GeneratorProviderDeclaration provider,
  ) {
    // TODO throw if a dependency is not accessible in the current library.
    final dependencies = provider.annotation.dependencies?.dependencies;
    if (dependencies == null) return null;

    final allTransitiveDependencies = <String>[];

    Iterable<GeneratorProviderDeclarationElement>
        computeAllTransitiveDependencies(
      GeneratorProviderDeclarationElement provider,
    ) sync* {
      final deps = provider.annotation.dependencies;
      if (deps == null) return;

      final uniqueDependencies = <GeneratorProviderDeclarationElement>{};

      for (final transitiveDependency in deps) {
        if (!uniqueDependencies.add(transitiveDependency)) continue;
        yield transitiveDependency;
        yield* computeAllTransitiveDependencies(transitiveDependency);
      }
    }

    final uniqueDependencies = <GeneratorProviderDeclarationElement>{};
    for (final dependency in dependencies) {
      if (!uniqueDependencies.add(dependency.provider)) continue;

      // TODO verify that the provider is accessible in the current library
      allTransitiveDependencies.add(dependency.provider.providerName(options));

      final uniqueTransitiveDependencies =
          computeAllTransitiveDependencies(dependency.provider)
              // Since generated code trims duplicate dependencies,
              // we have to trim them back when parsing the dependencies to
              // keep the index correct.
              .toSet()
              .indexed;

      for (final (index, transitiveDependency)
          in uniqueTransitiveDependencies) {
        if (!uniqueDependencies.add(transitiveDependency)) continue;

        // TODO verify that the provider is accessible in the current library
        allTransitiveDependencies.add(
          '${dependency.provider.providerTypeName}.\$allTransitiveDependencies$index',
        );
      }
    }

    return allTransitiveDependencies;
  }

  @override
  void visitClassBasedProviderDeclaration(
    ClassBasedProviderDeclaration provider,
  ) {
    super.visitClassBasedProviderDeclaration(provider);
    visitGeneratorProviderDeclaration(provider);
    NotifierTemplate(provider).run(buffer);
  }

  @override
  void visitFunctionalProviderDeclaration(
    FunctionalProviderDeclaration provider,
  ) {
    super.visitFunctionalProviderDeclaration(provider);
    RefTemplate(provider).run(buffer);
    visitGeneratorProviderDeclaration(provider);
  }
}

extension ProviderElementNames on GeneratorProviderDeclarationElement {
  String providerName(BuildYamlOptions options) {
    final suffix = isFamily
        ? options.providerFamilyNameSuffix
        : options.providerNameSuffix;

    return '${name.lowerFirst}${suffix ?? 'Provider'}';
  }

  String get providerTypeName => '${name.titled}Provider';
  String get refImplName => switch (this) {
        ClassBasedProviderDeclarationElement() => 'Ref',
        FunctionalProviderDeclarationElement() => '${name.titled}Ref'
      };

  String get familyTypeName => '${name.titled}Family';

  String dependencies(BuildYamlOptions options) {
    final dependencies = annotation.dependencies;
    if (dependencies == null) return 'null';

    final buffer = StringBuffer('const <ProviderOrFamily>');
    buffer.write('[');

    buffer.writeAll(
      dependencies.map((e) => e.providerName(options)),
      ',',
    );

    buffer.write(']');
    return buffer.toString();
  }

  String allTransitiveDependencies(List<String>? allTransitiveDependencies) {
    if (allTransitiveDependencies == null) return 'null';

    final buffer = StringBuffer('const <ProviderOrFamily>');
    if (allTransitiveDependencies.length < 4) {
      buffer.write('[');
    } else {
      buffer.write('{');
    }

    for (var i = 0; i < allTransitiveDependencies.length; i++) {
      buffer.write('$providerTypeName.\$allTransitiveDependencies$i,');
    }

    if (allTransitiveDependencies.length < 4) {
      buffer.write(']');
    } else {
      buffer.write('}');
    }

    return buffer.toString();
  }
}

extension ProviderNames on GeneratorProviderDeclaration {
  String providerName(BuildYamlOptions options) {
    return providerElement.providerName(options);
  }

  String get providerTypeName => providerElement.providerTypeName;
  String get refImplName => providerElement.refImplName;
  String get refWithGenerics {
    switch (this) {
      case FunctionalProviderDeclaration():
        return '${providerElement.refImplName}${generics()}';
      case ClassBasedProviderDeclaration():
        return '${providerElement.refImplName}<$exposedTypeDisplayString>';
    }
  }

  String get familyTypeName => providerElement.familyTypeName;

  String get argumentRecordType {
    switch (parameters) {
      case [_]:
        return parameters.first.typeDisplayString;
      case []:
        return 'Never';
      case [...]:
        return '(${buildParamDefinitionQuery(parameters, asRecord: true)})';
    }
  }

  String argumentToRecord({String? variableName}) {
    switch (parameters) {
      case [final p]:
        return variableName ?? p.name.toString();
      case [...]:
        return '(${buildParamInvocationQuery({
              for (final parameter in parameters)
                if (variableName != null)
                  parameter: '$variableName.${parameter.name}'
                else
                  parameter: parameter.name.toString(),
            })})';
    }
  }

  // TODO possibly no-longer needed
  String dependencies(BuildYamlOptions options) =>
      providerElement.dependencies(options);
  // TODO possibly no-longer needed
  String allTransitiveDependencies(List<String>? allTransitiveDependencies) {
    return providerElement.allTransitiveDependencies(allTransitiveDependencies);
  }

  TypeParameterList? get typeParameters => switch (this) {
        final FunctionalProviderDeclaration p =>
          p.node.functionExpression.typeParameters,
        final ClassBasedProviderDeclaration p => p.node.typeParameters
      };

  String generics() => _genericUsageDisplayString(typeParameters);
  String genericsDefinition() =>
      _genericDefinitionDisplayString(typeParameters);

  String createType({bool withArguments = true}) {
    final generics = this.generics();

    final provider = this;
    switch (provider) {
      case FunctionalProviderDeclaration():
        final params = withArguments
            ? buildParamDefinitionQuery(
                parameters,
                withDefaults: false,
              )
            : '';

        final refType = '${provider.refImplName}$generics';
        return '${provider.createdTypeDisplayString} Function($refType ref, $params)';
      case ClassBasedProviderDeclaration():
        return '${provider.name}$generics Function()';
    }
  }

  String get elementName => switch (this) {
        ClassBasedProviderDeclaration() => switch (createdType) {
            SupportedCreatedType.future => r'$AsyncNotifierProviderElement',
            SupportedCreatedType.stream => r'$StreamNotifierProviderElement',
            SupportedCreatedType.value => r'$NotifierProviderElement',
          },
        FunctionalProviderDeclaration() => switch (createdType) {
            SupportedCreatedType.future => r'$FutureProviderElement',
            SupportedCreatedType.stream => r'$StreamProviderElement',
            SupportedCreatedType.value => r'$ProviderElement',
          },
      };

  String get hashFnName => '_\$${providerElement.name.public.lowerFirst}Hash';

  List<FormalParameter> get parameters {
    final provider = this;
    switch (provider) {
      case FunctionalProviderDeclaration():
        return provider.node.functionExpression.parameters!.parameters
            .skip(1)
            .toList();
      case ClassBasedProviderDeclaration():
        return provider.buildMethod.parameters!.parameters.toList();
    }
  }
}

String _genericDefinitionDisplayString(TypeParameterList? typeParameters) {
  return typeParameters?.toSource() ?? '';
}

String _genericUsageDisplayString(TypeParameterList? typeParameterList) {
  if (typeParameterList == null) {
    return '';
  }

  return '<${typeParameterList.typeParameters.map((e) => e.name.lexeme).join(', ')}>';
}
