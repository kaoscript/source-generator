/**
 * generator.ks
 * Version 0.1.0
 * August 14th, 2017
 *
 * Copyright (c) 2017 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
#![error(ignore(Error))]

include {
	'npm:@kaoscript/ast'
	'npm:@kaoscript/source-writer'
}

export namespace KSGeneration {
	var AssignmentOperatorSymbol = {
		`\(OperatorKind.Addition)`				: ' += '
		`\(OperatorKind.BitwiseAnd)`			: ' +&= '
		`\(OperatorKind.BitwiseLeftShift)`		: ' +<= '
		`\(OperatorKind.BitwiseOr)`				: ' +|= '
		`\(OperatorKind.BitwiseRightShift)`		: ' +>= '
		`\(OperatorKind.BitwiseXor)`			: ' +^= '
		`\(OperatorKind.Division)`				: ' /= '
		`\(OperatorKind.Empty)`					: ' !?#= '
		`\(OperatorKind.EmptyCoalescing)`		: ' ?##= '
		`\(OperatorKind.Equals)`				: ' = '
		`\(OperatorKind.Existential)`			: ' ?= '
		`\(OperatorKind.Finite)`				: ' ?+= '
		`\(OperatorKind.IntegerDivision)`		: ' /#= '
		`\(OperatorKind.LogicalAnd)`			: ' &&= '
		`\(OperatorKind.LogicalOr)`				: ' ||= '
		`\(OperatorKind.LogicalXor)`			: ' ^^= '
		`\(OperatorKind.Modulus)`				: ' %%= '
		`\(OperatorKind.Multiplication)`		: ' *= '
		`\(OperatorKind.NonEmpty)`				: ' ?#= '
		`\(OperatorKind.NonExistential)`		: ' !?= '
		`\(OperatorKind.NonFinite)`				: ' !?+= '
		`\(OperatorKind.NonFiniteCoalescing)`	: ' ?++= '
		`\(OperatorKind.NullCoalescing)`		: ' ??= '
		`\(OperatorKind.Power)`					: ' **= '
		`\(OperatorKind.Remainder)`				: ' %= '
		`\(OperatorKind.Return)`				: ' <- '
		`\(OperatorKind.Subtraction)`			: ' -= '
		`\(OperatorKind.VariantNoCoalescing)`	: ' ?]]= '
		`\(OperatorKind.VariantNo)`				: ' !?]= '
		`\(OperatorKind.VariantYes)`			: ' ?]= '
	}

	var BinaryOperatorSymbol = {
		`\(OperatorKind.Addition)`				: ' + '
		`\(OperatorKind.BitwiseAnd)`			: ' +& '
		`\(OperatorKind.BitwiseLeftShift)`		: ' +< '
		`\(OperatorKind.BitwiseOr)`				: ' +| '
		`\(OperatorKind.BitwiseRightShift)`		: ' +> '
		`\(OperatorKind.BitwiseXor)`			: ' +^ '
		`\(OperatorKind.Division)`				: ' / '
		`\(OperatorKind.Equality)`				: ' == '
		`\(OperatorKind.EmptyCoalescing)`		: ' ?## '
		`\(OperatorKind.EuclideanDivision)`		: ' /& '
		`\(OperatorKind.GreaterThan)`			: ' > '
		`\(OperatorKind.GreaterThanOrEqual)`	: ' >= '
		`\(OperatorKind.Inequality)`			: ' != '
		`\(OperatorKind.IntegerDivision)`		: ' /# '
		`\(OperatorKind.LessThan)`				: ' < '
		`\(OperatorKind.LessThanOrEqual)`		: ' <= '
		`\(OperatorKind.LogicalAnd)`			: ' && '
		`\(OperatorKind.LogicalImply)`			: ' -> '
		`\(OperatorKind.LogicalOr)`				: ' || '
		`\(OperatorKind.LogicalXor)`			: ' ^^ '
		`\(OperatorKind.Match)`					: ' ~~ '
		`\(OperatorKind.Mismatch)`				: ' !~ '
		`\(OperatorKind.Modulus)`				: ' %% '
		`\(OperatorKind.Multiplication)`		: ' * '
		`\(OperatorKind.NonFiniteCoalescing)`	: ' ?++ '
		`\(OperatorKind.NullCoalescing)`		: ' ?? '
		`\(OperatorKind.Power)`					: ' ** '
		`\(OperatorKind.Remainder)`				: ' % '
		`\(OperatorKind.Subtraction)`			: ' - '
		`\(OperatorKind.TypeAssertion)`			: ':&'
		`\(OperatorKind.TypeCasting)`			: ':>'
		`\(OperatorKind.TypeEquality)`			: ' is '
		`\(OperatorKind.TypeInequality)`		: ' is not '
		`\(OperatorKind.VariantNoCoalescing)`	: ' ?]] '
	}

	var JunctionOperatorSymbol = {
		`\(OperatorKind.JunctionAnd)`			: ' & '
		`\(OperatorKind.JunctionOr)`			: ' | '
		`\(OperatorKind.JunctionXor)`			: ' ^ '
	}

	var UnaryPrefixOperatorSymbol = {
		`\(OperatorKind.BitwiseNegation)`		: '+^'
		`\(OperatorKind.Constant)`				: 'const '
		`\(OperatorKind.Existential)`			: '?'
		`\(OperatorKind.Finite)`				: '?+'
		`\(OperatorKind.Implicit)`				: '.'
		`\(OperatorKind.Length)`				: '#'
		`\(OperatorKind.LogicalNegation)`		: '!'
		`\(OperatorKind.Negative)`				: '-'
		`\(OperatorKind.NonEmpty)`				: '?#'
		`\(OperatorKind.Spread)`				: '...'
		`\(OperatorKind.VariantYes)`			: '?]'
	}

	enum KSWriterMode {
		Default
		Export
		Extern
		Import
		Property
		// Syntime
		Type
	}

	enum AttributeMode {
		Inline
		Inner
		Outer
	}

	enum ExpressionMode {
		Default
		Disruptive
		Rolling
		Top
	}

	func $nilFilter(...) { # {{{
		return false
	} # }}}

	func $nilTransformer(...args) { # {{{
		return args[0]
	} # }}}

	class KSWriter extends SourceGeneration.Writer {
		private {
			@filterExpression
			@filterStatement
			@filterStack: Array				= []
			@mode: KSWriterMode
			@references: Function[]{}		= {}
			@modeStack: Array				= []
		}
		constructor(options? = null) { # {{{
			super(Object.merge({
				mode: KSWriterMode.Default
				classes: {
					block: KSBlockWriter
					control: KSControlWriter
					expression: KSExpressionWriter
					line: KSLineWriter
					mark: KSMarkWriter
					object: KSObjectWriter
				}
				filters: {
					expression: $nilFilter
					statement: $nilFilter
				}
				terminators: {
					line: ''
					list: ''
				}
				transformers: {
					expression: $nilTransformer
					statement: $nilTransformer
				}
			}, options))

			@filterExpression = @options.filters.expression
			@filterStatement = @options.filters.statement

			@mode = @options.mode
		} # }}}
		filterExpression(data, writer = this) => this._filterExpression(data, writer)
		filterStatement(data, writer = this) => this._filterStatement(data, writer)
		getReference(name: String): Function? { # {{{
			if var functions ?#= @references[name] {
				return functions[0]
			}

			return null
		} # }}}
		mode() => @mode
		popFilters(): Void { # {{{
			@filterStatement = @filterStack.pop()
			@filterExpression = @filterStack.pop()
		} # }}}
		popMode(): Void { # {{{
			@mode = @modeStack.pop()
		} # }}}
		popReference(name: String): Void { # {{{
			if var functions ?#= @references[name] {
				functions.shift()
			}
		} # }}}
		pushFilters(expressionFilter, statementFilter) { # {{{
			@filterStack.push(@filterExpression, @filterStatement)
			@filterExpression = expressionFilter
			@filterStatement = statementFilter
		} # }}}
		pushMode(mode: KSWriterMode) { # {{{
			@modeStack.push(@mode)

			@mode = mode
		} # }}}
		pushReference(name: String, fn: Function): Void { # {{{
			if var functions ?= @references[name] {
				functions.unshift(fn)
			}
			else {
				@references[name] = [fn]
			}
		} # }}}
		statement(data) { # {{{
			if !this.filterStatement(data) {
				toAttributes(data, AttributeMode.Outer, this)

				toStatement(this.transformStatement(data), this)
			}

			return this
		} # }}}
		toSource() { # {{{
			var dyn source = ''

			for var fragment in this.toArray() {
				source += fragment.code
			}

			if source.length != 0 {
				return source.substr(0, source.length - 1)
			}
			else {
				return source
			}
		} # }}}
		transformExpression(data, writer = this) => @options.transformers.expression(data, writer)
		transformStatement(data, writer = this) => @options.transformers.statement(data, writer)
	}

	class KSBlockWriter extends SourceGeneration.BlockWriter {
		expression(data, mode: ExpressionMode = ExpressionMode.Default) { # {{{
			if !this.filterExpression(data) {
				match @mode() {
					KSWriterMode.Export {
						toExport(this.transformExpression(data), this)
					}
					KSWriterMode.Import {
						toImport(this.transformExpression(data), this)
					}
					else {
						toExpression(this.transformExpression(data), mode, this)
					}
				}
			}

			return this
		} # }}}
		filterExpression(data) => @writer.filterExpression(data, this)
		filterStatement(data) => @writer.filterStatement(data, this)
		getReference(name) => @writer.getReference(name)
		mode() => @writer.mode()
		popFilters() => @writer.popFilters()
		popMode() => @writer.popMode()
		popReference(name) => @writer.popReference(name)
		pushFilters(expressionFilter, statementFilter) => @writer.pushFilters(expressionFilter, statementFilter)
		pushMode(mode: KSWriterMode) => @writer.pushMode(mode)
		pushReference(name, fn) => @writer.pushReference(name, fn)
		statement(data) { # {{{
			if !this.filterStatement(data) {
				toAttributes(data, AttributeMode.Outer, this)

				toStatement(this.transformStatement(data), this)
			}

			return this
		} # }}}
		transformExpression(data, writer = this) => @writer.transformExpression(data, this)
		transformStatement(data, writer = this) => @writer.transformStatement(data, this)
	}

	class KSControlWriter extends SourceGeneration.ControlWriter {
		expression(data, mode: ExpressionMode = ExpressionMode.Default) { # {{{
			if !this.filterExpression(data) {
				toExpression(this.transformExpression(data), mode, this)
			}

			return this
		} # }}}
		filterExpression(data) => @writer.filterExpression(data, this)
		filterStatement(data) => @writer.filterStatement(data, this)
		getReference(name) => @writer.getReference(name)
		mode() => @writer.mode()
		popMode() => @writer.popMode()
		popReference(name) => @writer.popReference(name)
		pushMode(mode: KSWriterMode) => @writer.pushMode(mode)
		pushReference(name, fn) => @writer.pushReference(name, fn)
		statement(data) { # {{{
			if !this.filterStatement(data) {
				toAttributes(data, AttributeMode.Outer, this)

				toStatement(this.transformStatement(data), this)
			}

			return this
		} # }}}
		transformExpression(data, writer = this) => @writer.transformExpression(data, this)
		transformStatement(data, writer = this) => @writer.transformStatement(data, this)
		wrap(data) { # {{{
			if !this.filterExpression(data) {
				toWrap(this.transformExpression(data), this)
			}

			return this
		} # }}}
	}

	class KSExpressionWriter extends SourceGeneration.ExpressionWriter {
		expression(data, mode: ExpressionMode = ExpressionMode.Default) { # {{{
			if !this.filterExpression(data) {
				toExpression(this.transformExpression(data), mode, this)
			}

			return this
		} # }}}
		filterExpression(data) => @writer.filterExpression(data, this)
		getReference(name) => @writer.getReference(name)
		mode() => @writer.mode()
		popMode() => @writer.popMode()
		popReference(name) => @writer.popReference(name)
		pushMode(mode: KSWriterMode) => @writer.pushMode(mode)
		pushReference(name, fn) => @writer.pushReference(name, fn)
		run(data, fn) { # {{{
			fn(data, this)

			return this
		} # }}}
		transformExpression(data, writer = this) => @writer.transformExpression(data, this)
		wrap(data) { # {{{
			if !this.filterExpression(data) {
				toWrap(this.transformExpression(data), this)
			}

			return this
		} # }}}
	}

	class KSLineWriter extends SourceGeneration.LineWriter {
		expression(data, mode: ExpressionMode = ExpressionMode.Default) { # {{{
			if !this.filterExpression(data) {
				match @mode() {
					KSWriterMode.Export {
						toExport(this.transformExpression(data), this)
					}
					KSWriterMode.Import {
						toImport(this.transformExpression(data), this)
					}
					else {
						toExpression(this.transformExpression(data), mode, this)
					}
				}
			}

			return this
		} # }}}
		filterExpression(data) => @writer.filterExpression(data, this)
		filterStatement(data) => @writer.filterStatement(data, this)
		getReference(name) => @writer.getReference(name)
		mode() => @writer.mode()
		popIndent(): valueof this { # {{{
			@indent -= 1
		} # }}}
		popMode() => @writer.popMode()
		popReference(name) => @writer.popReference(name)
		pushIndent(): valueof this { # {{{
			@indent += 1
		} # }}}
		pushMode(mode: KSWriterMode) => @writer.pushMode(mode)
		pushReference(name, fn) => @writer.pushReference(name, fn)
		run(data, fn) { # {{{
			fn(data, this)

			return this
		} # }}}
		statement(data) { # {{{
			if !this.filterStatement(data) {
				toAttributes(data, AttributeMode.Outer, this)

				toStatement(this.transformStatement(data), this)
			}

			return this
		} # }}}
		transformExpression(data, writer = this) => @writer.transformExpression(data, this)
		transformStatement(data, writer = this) => @writer.transformStatement(data, this)
		wrap(data) { # {{{
			if !this.filterExpression(data) {
				toWrap(this.transformExpression(data), this)
			}

			return this
		} # }}}
	}

	class KSObjectWriter extends SourceGeneration.ObjectWriter {
		filterExpression(data) => @writer.filterExpression(data, this)
		filterStatement(data) => @writer.filterStatement(data, this)
		getReference(name) => @writer.getReference(name)
		mode() => @writer.mode()
		popMode() => @writer.popMode()
		popReference(name) => @writer.popReference(name)
		pushMode(mode: KSWriterMode) => @writer.pushMode(mode)
		pushReference(name, fn) => @writer.pushReference(name, fn)
		statement(data) { # {{{
			if !this.filterStatement(data) {
				toAttributes(data, AttributeMode.Outer, this)

				toStatement(this.transformStatement(data), this)
			}

			return this
		} # }}}
		transformExpression(data, writer = this) => @writer.transformExpression(data, this)
		transformStatement(data, writer = this) => @writer.transformStatement(data, this)
	}

	class KSMarkWriter extends SourceGeneration.MarkWriter {
		filterExpression(data, writer = this) => @writer.filterExpression(data, writer)
		filterStatement(data, writer = this) => @writer.filterStatement(data, writer)
		mode() => @writer.mode()
		transformExpression(data, writer = this) => @writer.transformExpression(data, writer)
		transformStatement(data, writer = this) => @writer.transformStatement(data, writer)
	}

	func isDifferentName(a, b): Boolean { # {{{
		match b.kind {
			AstKind.Identifier {
				return a.name != b.name
			}
			AstKind.ThisExpression {
				return a.name != b.name.name
			}
		}

		return true
	} # }}}

	func generate(data: Ast, options? = null) { # {{{
		var writer = KSWriter.new(options)

		toStatement(data, writer)

		return writer.toSource()
	} # }}}

	func hasModifier(data, target: ModifierKind): Boolean { # {{{
		for var modifier in data.modifiers {
			if modifier.kind == target {
				return true
			}
		}

		return false
	} # }}}

	func toAttribute(data, mode: AttributeMode, writer) { # {{{
		return writer
			.code(if mode == AttributeMode.Inner set '#![' else '#[')
			.expression(data.declaration)
			.code(']')
	} # }}}

	func toAttributes(data, mode: AttributeMode, writer) { # {{{
		if ?#data.attributes {
			if mode == AttributeMode.Inline {
				for var attribute in data.attributes {
					toAttribute(attribute, mode, writer).code(' ')
				}
			}
			else {
				for var attribute in data.attributes {
					toAttribute(attribute, mode, writer.newLine()).done()
				}

				if mode == AttributeMode.Inner {
					writer.newLine().done()
				}
			}
		}
	} # }}}

	func toComprehension(data, writer) { # {{{
		match data.kind {
			IterationKind.Repeat {
				writer.code(' repeat ').expression(data.expression).code(' times')
			}
			else {
				writer.code(' for ').run(data, toIteration)
			}
		}
	} # }}}

	func toExport(data, writer) {
		match data.kind {
			AstKind.DeclarationSpecifier { # {{{
				writer
					..pushMode(KSWriterMode.Default)
					..statement(data.declaration)
					..popMode()
			} # }}}
			AstKind.GroupSpecifier { # {{{
				var mut exclusion = false
				var mut wildcard = false

				for var modifier in data.modifiers {
					if modifier.kind == ModifierKind.Exclusion {
						exclusion = true
					}
					else if modifier.kind == ModifierKind.Wildcard {
						wildcard = true
					}
				}

				if exclusion {
					writer.code('* but ')

					for var element, index in data.elements {
						if index > 0 {
							writer.code(', ')
						}

						writer.expression(element)
					}
				}
				else if wildcard {
					writer.code('*')
				}
				else {
					if data.elements.length == 1 {
						writer.code(' for ').expression(data.elements[0])
					}
					else {
						writer.code(' for')

						var block = writer.newBlock()

						for var element in data.elements {
							block.newLine().expression(element).done()
						}

						block.done()
					}
				}
			} # }}}
			AstKind.NamedSpecifier { # {{{
				writer.expression(data.internal)

				if ?data.external {
					writer.code(` => \(data.external.name)`)
				}
				else {
					for var modifier in data.modifiers {
						if modifier.kind == ModifierKind.Wildcard {
							writer.code(' for *')

							break
						}
					}

				}
			} # }}}
			AstKind.PropertiesSpecifier { # {{{
				var line = writer.newLine()

				line.expression(data.object)

				if data.properties.length == 1 {
					line.code(' for ').statement(data.dpropertieseclarations[0])
				}
				else {
					var block = line.code(' for').newBlock()

					for var property in data.properties {
						block.statement(property)
					}

					block.done()
				}

				line.done()
			} # }}}
			else { # {{{
				toExpression(data, ExpressionMode.Top, writer)
			} # }}}
		}
	}

	func toExpression(mut data, mode: ExpressionMode, writer, header? = null) {
		match data.kind {
			AstKind.ArrayBinding { # {{{
				writer.code('[')

				for var element, index in data.elements {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(element)
				}

				writer.code(']')
			} # }}}
			AstKind.ArrayComprehension { # {{{
				writer
					.code('[')
					.expression(data.value)
					.run(data.iteration, toComprehension)
					.code(']')
			} # }}}
			AstKind.ArrayExpression { # {{{
				writer.code('[')

				for var value, index in data.values {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(value)
				}

				writer.code(']')
			} # }}}
			AstKind.ArrayRange { # {{{
				writer.code('[')

				if ?data.from {
					writer.expression(data.from)
				}
				else {
					writer.expression(data.then).code('<')
				}

				if ?data.to {
					writer.code('..').expression(data.to)
				}
				else {
					writer.code('..<').expression(data.til)
				}

				if ?data.by {
					writer.code('..').expression(data.by)
				}

				writer.code(']')
			} # }}}
			AstKind.ArrayType { # {{{
				if ?#data.properties {
					writer.code('[')

					for var property, index in data.properties {
						writer.code(', ') if index > 0

						writer.expression(property)
					}

					if ?data.rest {
						writer.code(', ...').expression(data.rest)
					}

					writer.code(']')
				}
				else {
					if ?data.rest {
						writer.expression(data.rest)
					}

					writer.code('[]')
				}

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Nullable {
							writer.code('?')
						}
					}
				}
			} # }}}
			AstKind.AttributeExpression { # {{{
				writer.expression(data.name).code('(')

				for var argument, index in data.arguments {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(argument)
				}

				writer.code(')')
			} # }}}
			AstKind.AttributeOperation { # {{{
				writer
					.expression(data.name)
					.code(' = ')
					.expression(data.value)
			} # }}}
			AstKind.AwaitExpression { # {{{
				writer.code('await')

				writer.code(' ').expression(data.operation) if ?data.operation
			} # }}}
			AstKind.BinaryExpression { # {{{
				match data.operator.kind {
					OperatorKind.Assignment {
						writer.wrap(data.left).code(AssignmentOperatorSymbol[data.operator.assignment])

						if mode == .Rolling && data.right.kind == AstKind.RollingExpression {
							writer
								.code('(')
								.pushIndent()
								.code('\n')
								.newIndent()
								.expression(data.right)
								.popIndent()
								.code('\n')
								.newIndent()
								.code(')')
						}
						else {
							writer.wrap(data.right)
						}
					}
					OperatorKind.BackwardPipeline, OperatorKind.ForwardPipeline {
						var mut existential = false
						var mut nonEmpty = false
						var mut destructuring = false

						for var { kind } in data.operator.modifiers {
							match ModifierKind(kind) {
								.Existential {
									existential = true
								}
								.NonEmpty {
									nonEmpty = true
								}
								.Wildcard {
									destructuring = true
								}
							}
						}

						writer.wrap(data.left)

						if data.operator.kind == OperatorKind.BackwardPipeline {
							writer
								..code(' ')
								..code('?') if existential
								..code('#') if nonEmpty
								..code('<|')
								..code('*') if destructuring
								..code(' ')
						}
						else {
							writer
								..code(' ')
								..code('*') if destructuring
								..code('|>')
								..code('?') if existential
								..code('#') if nonEmpty
								..code(' ')
						}

						writer.expression(data.right)
					}
					OperatorKind.TypeSignalment {
						writer.expression(data.left).code(':!')

						for var modifier in data.operator.modifiers {
							if modifier.kind == ModifierKind.Forced {
								writer.code('!')
							}
						}

						writer.code('(').expression(data.right).code(')')
					}
					OperatorKind.TypeAssertion, OperatorKind.TypeCasting {
						writer.expression(data.left).code(BinaryOperatorSymbol[data.operator.kind])

						for var modifier in data.operator.modifiers {
							if modifier.kind == ModifierKind.Nullable {
								writer.code('?')
							}
						}

						writer.code('(').expression(data.right).code(')')
					}
					else {
						writer
							.wrap(data.left)
							.code(BinaryOperatorSymbol[data.operator.kind])
							.wrap(data.right)
					}
				}
			} # }}}
			AstKind.BindingElement { # {{{
				toAttributes(data, AttributeMode.Inline, writer)

				var dyn computed = false
				var dyn thisAlias = false
				var dyn rest = false

				for var modifier in data.modifiers {
					if modifier.kind == ModifierKind.Computed {
						computed = true
					}
					else if modifier.kind == ModifierKind.Rest {
						writer.code('...')

						rest = true
					}
					else if modifier.kind == ModifierKind.ThisAlias {
						thisAlias = true
					}
				}

				if ?data.external && isDifferentName(data.external, data.internal) {
					if computed {
						writer.code('[').expression(data.external).code(']')
					}
					else {
						writer.expression(data.external)
					}

					writer.code(' % ')
				}

				if ?data.internal {
					writer.expression(data.internal)

					for var modifier in data.modifiers {
						match modifier.kind {
							ModifierKind.Required {
								writer.code('!')
							}
						}
					}
				}
				else if !rest || ?data.external {
					writer.code('_')
				}

				toType(data, writer)

				if ?data.defaultValue {
					writer.code(AssignmentOperatorSymbol[data.operator.assignment]).expression(data.defaultValue)
				}
			} # }}}
			AstKind.Block { # {{{
				toAttributes(data, AttributeMode.Inner, writer)

				for var statement in data.statements {
					writer.statement(statement)
				}
			} # }}}
			AstKind.CallExpression { # {{{
				writer.expression(data.callee, mode)

				if data.modifiers.some((modifier, ...) => modifier.kind == ModifierKind.Nullable) {
					writer.code('?')
				}

				match data.scope.kind {
					ScopeKind.Argument {
						writer
							.code('*$(')
							.expression(data.scope.value)

						if data.arguments.length != 0 {
							writer.code(', ')
						}
					}
					ScopeKind.This {
						writer.code('(')
					}
				}

				for var argument, index in data.arguments {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(argument)
				}

				writer.code(')')
			} # }}}
			AstKind.ClassDeclaration { # {{{
				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Abstract {
							writer.code('abstract ')
						}
						ModifierKind.Sealed {
							writer.code('sealed ')
						}
					}
				}

				writer.code('class ').expression(data.name)

				if ?data.typeParameters {
					toTypeParameters(data.typeParameters, writer)
				}
			} # }}}
			AstKind.ComparisonExpression { # {{{
				for var value, i in data.values {
					if i % 2 == 0 {
						writer.wrap(value)
					}
					else {
						writer.code(BinaryOperatorSymbol[value.kind])
					}
				}
			} # }}}
			AstKind.ComputedPropertyName { # {{{
				writer
					.code('[')
					.expression(data.expression)
					.code(']')
			} # }}}
			AstKind.CurryExpression { # {{{
				writer.expression(data.callee)

				match data.scope.kind {
					ScopeKind.Argument {
						writer
							.code('^$(')
							.expression(data.scope.value)

						if data.arguments.length {
							writer.code(', ')
						}
					}
					ScopeKind.This {
						writer.code('^^(')
					}
				}

				for var argument, index in data.arguments {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(argument)
				}

				writer.code(')')
			} # }}}
			AstKind.DisruptiveExpression { # {{{
				var simpleTop = mode == .Top && data.mainExpression.kind == AstKind.Identifier

				writer.pushReference('main', (writer) => {
					writer
						.expression(data.mainExpression, ExpressionMode.Disruptive)
						.code('\n').newIndent() if !simpleTop
				})

				writer.expression(data.disruptedExpression)

				writer.popReference('main')

				match data.operator.kind {
					RestrictiveOperatorKind.If {
						writer.code(' if ')
					}
					RestrictiveOperatorKind.Unless {
						writer.code(' unless ')
					}
				}

				writer.expression(data.condition)

				if mode != .Top & .Disruptive {
					writer.code('\n').newIndent()
				}
			} # }}}
			AstKind.ExclusionType { # {{{
				for var type, index in data.types {
					if index != 0 {
						writer.code(if type.kind == AstKind.FunctionExpression set ' ^^ ' else ' ^ ')
					}

					writer.expression(type)
				}
			} # }}}
			AstKind.FunctionDeclaration { # {{{
				toFunctionHeader(data, writer => writer.code('func '), writer)
			} # }}}
			AstKind.FunctionExpression { # {{{
				toFunctionHeader(data, writer => {
					if writer.mode() == KSWriterMode.Type {
						header?(writer)
					}
					else {
						writer.code('func')
					}
				}, writer)

				if ?data.body {
					if data.body.kind == AstKind.Block {
						writer.newBlock().expression(data.body).done()
					}
					else {
						writer.code(' => ').expression(data.body)
					}
				}
			} # }}}
			AstKind.FusionType { # {{{
				for var type, index in data.types {
					if index != 0 {
						writer.code(if type.kind == AstKind.FunctionExpression set ' && ' else ' & ')
					}

					writer.expression(type)
				}
			} # }}}
			AstKind.Identifier { # {{{
				writer.code(data.name)
			} # }}}
			AstKind.IfExpression { # {{{
				var ctrl = writer.newControl(null, false, null, false).code('if ')

				if ?data.declaration {
					ctrl.expression(data.declaration)

					if ?data.condition {
						ctrl.code('; ').expression(data.condition)
					}
				}
				else if ?data.condition {
					ctrl.expression(data.condition)
				}

				ctrl.step()

				if data.whenTrue.kind == AstKind.SetStatement {
					ctrl
						.statement(data.whenTrue)
						.step()
						.code('else')
						.step()
						.statement(data.whenFalse)
				}
				else {
					ctrl.expression(data.whenTrue)

					while ?data.whenFalse {
						if data.whenFalse.kind == AstKind.IfExpression {
							data = data.whenFalse

							ctrl.step().code('else if ')

							if ?data.declaration {
								ctrl.expression(data.declaration)

								if ?data.condition {
									ctrl.code('; ').expression(data.condition)
								}
							}
							else if ?data.condition {
								ctrl.expression(data.condition)
							}

							ctrl.step().expression(data.whenTrue)
						}
						else {
							ctrl
								.step()
								.code('else')
								.step()
								.expression(data.whenFalse)

							break
						}
					}
				}

				ctrl.done()
			} # }}}
			AstKind.IncludeDeclarator { # {{{
				toAttributes(data, AttributeMode.Outer, writer)

				writer.newLine().code(toQuote(data.file)).done()
			} # }}}
			AstKind.JunctionExpression { # {{{
				var operator = JunctionOperatorSymbol[data.operator.kind]

				for var operand, i in data.operands {
					writer.code(operator) if i != 0

					writer.expression(operand)
				}
			} # }}}
			AstKind.LambdaExpression { # {{{
				toFunctionHeader(data, writer => {}, writer)

				if data.body.kind == AstKind.Block {
					writer
						.code(' =>')
						.newBlock()
						.expression(data.body)
						.done()
				}
				else {
					writer.code(' => ').expression(data.body)
				}
			} # }}}
			AstKind.Literal { # {{{
				var dyn multiline = false

				for var modifier in data.modifiers {
					if modifier.kind == ModifierKind.MultiLine {
						multiline = true
					}
				}

				if multiline {
					writer.code('"""\n').newIndent()

					var lines = data.value.split(/\n/g)

					for var line, index in lines {
						if index > 0 {
							writer.code('\n').newIndent()
						}

						writer.code(line)
					}

					writer.code('\n').newIndent().code('"""')
				}
				else {
					writer.code(toQuote(data.value))
				}
			} # }}}
			AstKind.MatchConditionArray { # {{{
				writer.code('[')

				for var value, index in data.values {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(value)
				}

				writer.code(']')
			} # }}}
			AstKind.MatchConditionObject { # {{{
				writer.code('{')

				for var property, index in data.properties {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(property)
				}

				writer.code('}')
			} # }}}
			AstKind.MatchConditionRange { # {{{
				if ?data.from {
					writer.expression(data.from)
				}
				else {
					writer.expression(data.then).code('<')
				}

				if ?data.to {
					writer.code('..').expression(data.to)
				}
				else {
					writer.code('..<').expression(data.til)
				}

				if ?data.by {
					writer.code('..').expression(data.by)
				}
			} # }}}
			AstKind.MatchConditionType { # {{{
				writer
					.code('is ')
					.expression(data.type)
			} # }}}
			AstKind.MatchExpression { # {{{
				writer
					.code('match ')
					.expression(data.expression)

				var block = writer.newBlock()

				for var clause in data.clauses {
					block.statement(clause)
				}

				block.done()
			} # }}}
			AstKind.MemberExpression { # {{{
				var dyn nullable = false
				var dyn computed = false

				for var modifier in data.modifiers {
					if modifier.kind == ModifierKind.Computed {
						computed = true
					}
					else if modifier.kind == ModifierKind.Nullable {
						nullable = true
					}
				}

				if mode == .Disruptive {
					writer.expression(data.object, mode).code('\n').newIndent()
				}
				else if ?data.object {
					writer.wrap(data.object)
				}

				if nullable {
					writer.code('?')
				}

				if computed {
					writer.code('[').expression(data.property).code(']')
				}
				else {
					writer.code('.').expression(data.property)
				}
			} # }}}
			AstKind.NamedArgument { # {{{
				writer.expression(data.name).code(': ').expression(data.value)
			} # }}}
			AstKind.NumericExpression { # {{{
				writer.code(data.value)
			} # }}}
			AstKind.ObjectBinding { # {{{
				writer.code('{')

				for var element, index in data.elements {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(element)
				}

				writer.code('}')
			} # }}}
			AstKind.ObjectComprehension { # {{{
				writer
					.code('{')
					.expression(data.name)
					.code(': ')
					.expression(data.value)
					.run(data.iteration, toComprehension)
					.code('}')
			} # }}}
			AstKind.ObjectExpression { # {{{
				var o = writer.newObject()

				toAttributes(data, AttributeMode.Inner, o)

				o.pushMode(KSWriterMode.Property)

				for var property in data.properties {
					toAttributes(property, AttributeMode.Outer, o)

					o.newLine().expression(property).done()
				}

				o.popMode()

				o.done()
			} # }}}
			AstKind.ObjectMember { # {{{
				var value = data.value ?? data.type
				if ?value {
					var element = writer.transformExpression(value)

					if ?data.name {
						writer.expression(data.name).code(': ').expression(element)
					}
					else {
						writer.code('...').expression(element)
					}
				}
				else {
					writer.expression(data.name)
				}
			} # }}}
			AstKind.ObjectType { # {{{
				if ?#data.properties {
					var o = writer.newObject()

					o.pushMode(KSWriterMode.Type)

					for var property, index in data.properties {
						o.newLine().expression(property).done()
					}

					if ?data.rest {
						o.newLine().code('...').expression(data.rest).done()
					}

					o.popMode()

					o.done()
				}
				else {
					if ?data.rest {
						writer.expression(data.rest)
					}

					writer.code('{}')
				}

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Nullable {
							writer.code('?')
						}
					}
				}
			} # }}}
			AstKind.OmittedExpression { # {{{
				if data.spread {
					writer.code('...')
				}
				else {
					writer.code('_')
				}
			} # }}}
			AstKind.Operator { # {{{
				match data.operator.kind {
					OperatorKind.Assignment {
						writer.code(AssignmentOperatorSymbol[data.operator.assignment].trim())
					}
					else {
						writer.code(BinaryOperatorSymbol[data.operator.kind].trim())
					}
				}
			} # }}}
			AstKind.Parameter { # {{{
				toAttributes(data, AttributeMode.Inline, writer)

				var mut rest: Boolean = false
				var mut only: Boolean = false

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Mutable {
							writer.code('mut ')
						}
						ModifierKind.NameOnly {
							writer.code('*')

							only = true
						}
						ModifierKind.PositionOnly {
							writer.code('#')

							only = true
						}
						ModifierKind.Rest {
							rest = true
						}
					}
				}

				if !?data.external {
					if only || !?data.internal || data.internal.kind != AstKind.Identifier & AstKind.ThisExpression {
						pass
					}
					else {
						writer.code('_ % ')
					}
				}
				else if !?data.internal || (!?data.internal.alias && isDifferentName(data.external, data.internal)) {
					writer.expression(data.external).code(' % ')
				}
				else if ?data.internal.alias && !isDifferentName(data.external, data.internal.alias) {
					writer.expression(data.external).code(' & ')
				}

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Rest {
							writer.code('...')

							if modifier.arity.min != 0 || modifier.arity.max != Infinity {
								writer.code('{')

								if modifier.arity.min == modifier.arity.max {
									writer.code(modifier.arity.min)
								}
								else {
									if modifier.arity.min != 0 {
										writer.code(modifier.arity.min)
									}

									writer.code(',')

									if modifier.arity.max != Infinity {
										writer.code(modifier.arity.max)
									}
								}

								writer.code('}')
							}

							rest = true
						}
						ModifierKind.ThisAlias {
							writer.code('@')
						}
					}
				}

				if ?data.internal {
					writer.expression(data.internal)

					if ?data.internal.alias && !?data.external {
						writer.code(' & ').expression(data.internal.alias)
					}

					for var modifier in data.modifiers {
						match modifier.kind {
							ModifierKind.NonNullable {
								writer.code('!?')
							}
							ModifierKind.Required {
								writer.code('!')
							}
						}
					}
				}
				else if !rest || ?data.external {
					writer.code('_')
				}

				toType(data, writer)

				if ?data.defaultValue {
					writer.code(AssignmentOperatorSymbol[data.operator.assignment]).expression(data.defaultValue)
				}
			} # }}}
			AstKind.PlaceholderArgument { # {{{
				var mut rest = false

				for var modifier in data.modifiers {
					if modifier.kind == ModifierKind.Rest {
						rest = true

						break
					}
				}

				writer.code(if rest set '...' else '^')

				if ?data.index {
					writer.code(data.index.value)
				}
			} # }}}
			AstKind.PolyadicExpression { # {{{
				writer.wrap(data.operands[0])

				for var operand in data.operands from 1 {
					writer
						.code(BinaryOperatorSymbol[data.operator.kind])
						.wrap(operand)
				}
			} # }}}
			AstKind.PositionalArgument { # {{{
				writer.code('\\').expression(data.value)
			} # }}}
			AstKind.PropertyType { # {{{
				if ?data.name {
					if ?data.type {
						if data.type.kind == AstKind.FunctionExpression {
							toExpression(data.type, ExpressionMode.Top, writer, writer => writer.expression(data.name))
						}
						else if data.type.kind == AstKind.VariantType {
							writer.code('variant ').expression(data.name).code(': ').expression(data.type.master)

							if ?#data.type.properties {
								var block = writer.newBlock()

								for var property in data.type.properties {
									block.newLine().expression(property).done()
								}

								block.done()
							}
						}
						else {
							writer.expression(data.name).code(': ').expression(data.type)
						}
					}
					else {
						writer.expression(data.name)
					}
				}
				else if ?data.type {
					writer.expression(data.type)
				}

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Nullable {
							writer.code('?')
						}
					}
				}
			} # }}}
			AstKind.QuoteExpression { # {{{
				writer.code('quote ')

				if data.elements[0].start.line == data.elements[data.elements.length - 1].end.line {
					toQuoteElements(data.elements, writer)
				}
				else {
					var o = writer.newObject()

					var dyn line = o.newLine()

					toQuoteElements(data.elements, line, o)

					o.done()
				}
			} # }}}
			AstKind.Reference { # {{{
				if var reference ?= writer.getReference(data.name) {
					reference(writer)
				}
			} # }}}
			AstKind.RegularExpression { # {{{
				writer.code(data.value)
			} # }}}
			AstKind.RestrictiveExpression { # {{{
				writer.expression(data.expression)

				match data.operator.kind {
					RestrictiveOperatorKind.If {
						writer.code(' if ')
					}
					RestrictiveOperatorKind.Unless {
						writer.code(' unless ')
					}
				}

				writer.expression(data.condition)
			} # }}}
			AstKind.RollingExpression { # {{{
				toAttributes(data, AttributeMode.Inner, writer)

				writer.expression(data.object)

				if data.modifiers.some((modifier, ...) => modifier.kind == ModifierKind.Nullable) {
					writer.code('?')
				}

				for var expression in data.expressions {
					writer.code('\n').newIndent().code('.').expression(expression, ExpressionMode.Rolling)
				}
			} # }}}
			AstKind.SequenceExpression { # {{{
				writer.code('(')

				for var expression, index in data.expressions {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(expression)
				}

				writer.code(')')
			} # }}}
			AstKind.ShorthandProperty { # {{{
				writer.expression(data.name)
			} # }}}
			AstKind.SpreadExpression { # {{{
				writer
					.code('...')
					.expression(data.operand)
					.code(' ')

				var o = writer.newObject()

				for var member in data.members {
					var line = o.newLine()

					if ?member.external {
						line.code(`\(member.external.name) % \(member.internal.name)`)
					}
					else {
						line.code(member.internal.name)
					}

					line.done()
				}

				o.done()
			} # }}}
			AstKind.SyntimeCallExpression { # {{{
				writer
					.expression(data.callee, mode)
					.code('!(')
					.unlimit()

				for var argument, index in data.arguments {
					writer
						..code(', ') if index != 0
						..statement(argument)
				}

				writer.code(')')
			} # }}}
			AstKind.TaggedTemplateExpression { # {{{
				writer.expression(data.tag).expression(data.template)
			} # }}}
			AstKind.TemplateExpression { # {{{
				var dyn multiline = false

				for var modifier in data.modifiers {
					if modifier.kind == ModifierKind.MultiLine {
						multiline = true
					}
				}

				if multiline {
					writer.code('```\n').newIndent()

					for var element in data.elements {
						if element.kind == AstKind.Literal {
							var lines = element.value.split(/\n/g)

							for var line, index in lines {
								if index > 0 {
									writer.code('\n').newIndent()
								}

								writer.code(line)
							}
						}
						else {
							writer.code('\\(').expression(element).code(')')
						}
					}

					writer.code('\n').newIndent().code('```')
				}
				else {
					writer.code('`')

					for var element in data.elements {
						if element.kind == AstKind.Literal {
							writer.code(element.value)
						}
						else {
							writer.code('\\(').expression(element).code(')')
						}
					}

					writer.code('`')
				}
			} # }}}
			AstKind.TopicReference { # {{{
				for var { kind } in data.modifiers {
					if kind == ModifierKind.Spread {
						writer.code('...')

						return
					}
				}

				writer.code('_')
			} # }}}
			AstKind.ThisExpression { # {{{
				writer.code('@').expression(data.name)
			} # }}}
			AstKind.TryExpression { # {{{
				writer.code('try')

				if data.modifiers.some((modifier, ...) => modifier.kind == ModifierKind.Disabled) {
					writer.code('!')
				}

				writer.code(' ').expression(data.argument)

				if ?data.defaultValue {
					writer.code(' ~~ ').expression(data.defaultValue)
				}
			} # }}}
			AstKind.TypeParameter { # {{{
				writer.expression(data.name)

				if ?data.constraint {
					writer.code(' is ').expression(data.constraint)
				}
			} # }}}
			AstKind.TypeReference { # {{{
				if ?data.properties {
					var o = writer.newObject()

					o.pushMode(KSWriterMode.Property)

					for var property in data.properties {
						o.statement(property)
					}

					o.popMode()

					o.done()
				}
				else if ?data.elements {
					writer.code('[')

					for var element, index in data.elements {
						if index != 0 {
							writer.code(', ')
						}

						writer.expression(element)
					}

					writer.code(']')
				}
				else {
					for var modifier in data.modifiers {
						match modifier.kind {
							ModifierKind.Rest {
								writer.code('...')
							}
						}
					}

					writer.expression(data.typeName)

					if ?data.typeParameters {
						toTypeParameters(data.typeParameters, writer)
					}

					if ?data.typeSubtypes {
						writer.code('(')

						if data.typeSubtypes is Array {
							var prefix =
								if hasModifier(data.typeSubtypes[0], ModifierKind.Exclusion) {
									set '!'
								}
								else {
									set ''
								}

							for var subtype, index in data.typeSubtypes {
								if index != 0 {
									writer.code(', ')
								}

								writer.code(prefix).expression(subtype)
							}
						}
						else {
							writer.expression(data.typeSubtypes)
						}

						writer.code(')')
					}

					if data.modifiers.some((modifier, ...) => modifier.kind == ModifierKind.Nullable) {
						writer.code('?')
					}
				}
			} # }}}
			AstKind.TypedExpression { # {{{
				writer.expression(data.expression).code('<')

				for var type, index in data.typeParameters {
					writer
						.code(', ') if index > 0
						.expression(type)
				}

				writer.code('>')
			} # }}}
			AstKind.UnaryExpression { # {{{
				var mut forced = false
				var mut nullable = false

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Forced {
							forced = true
						}
						ModifierKind.Nullable {
							nullable = true
						}
					}
				}

				if var operator ?= UnaryPrefixOperatorSymbol[data.operator.kind] {
					writer
						.code(operator)
						.code('?') if nullable
						.wrap(data.argument)
				}
				else {
					writer.wrap(data.argument)

					match data.operator.kind {
						OperatorKind.TypeFitting {
							writer.code(if forced set '!!!' else '!!')
						}
						OperatorKind.TypeNotNull {
							writer.code('!?')
						}
					}
				}
			} # }}}
			AstKind.UnaryTypeExpression { # {{{
				match data.operator.kind {
					UnaryTypeOperatorKind.Constant {
						writer.code(`const `)
					}
					UnaryTypeOperatorKind.Mutable {
						writer.code(`mut `)
					}
					UnaryTypeOperatorKind.NewInstance {
						writer.code(`new `)
					}
					UnaryTypeOperatorKind.TypeOf {
						writer.code(`typeof `)
					}
					UnaryTypeOperatorKind.ValueOf {
						writer.code(`valueof `)
					}
				}

				writer.expression(data.argument)
			} # }}}
			AstKind.UnionType { # {{{
				for var type, index in data.types {
					if index != 0 {
						writer.code(if type.kind == AstKind.FunctionExpression set ' || ' else ' | ')
					}

					writer.expression(type)
				}
			} # }}}
			AstKind.VariableDeclaration { # {{{
				var mut declarative = false
				var mut mutable = false

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Declarative {
							declarative = true
						}
						ModifierKind.Mutable {
							mutable = true
						}
					}
				}

				if declarative {
					toAttributes(data, AttributeMode.Inline, writer)

					writer
						..code('var ')
						..code('mut ') if mutable
				}

				for var variable, index in data.variables {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(variable)
				}

				if ?data.value {
					if ?data.operator {
						writer.code(AssignmentOperatorSymbol[data.operator.assignment])
					}
					else {
						writer.code(' = ')
					}

					if data.await {
						writer.code('await ')
					}

					writer.expression(data.value, ExpressionMode.Top)
				}
			} # }}}
			AstKind.VariableDeclarator { # {{{
				var mut nullable = false

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Final {
							writer.code('final ')
						}
						ModifierKind.Nullable {
							nullable = true
						}
						ModifierKind.System {
							writer.code('system ')
						}
					}
				}

				writer.expression(data.name)

				writer.code('?') if nullable

				if ?data.type {
					writer.code(': ').expression(data.type)
				}
			} # }}}
			AstKind.VariantField { # {{{
				for var name, index in data.names {
					writer
						..code(', ') if index > 0
						..expression(name)
				}

				if ?data.type {
					writer.code(' ').expression(data.type)
				}
			} # }}}
			else { # {{{
				echo(data)
				throw Error.new('Not Implemented')
			} # }}}
		}
	}

	func toFunctionHeader(data, header, writer) { # {{{
		if ?data.modifiers {
			for var modifier in data.modifiers {
				match modifier.kind {
					ModifierKind.Abstract {
						writer.code('abstract ')
					}
					ModifierKind.Assist {
						writer.code('assist ')
					}
					ModifierKind.Async {
						writer.code('async ')
					}
					ModifierKind.Final {
						writer.code('final ')
					}
					ModifierKind.Internal {
						writer.code('internal ')
					}
					ModifierKind.Override {
						writer.code('override ')
					}
					ModifierKind.Overwrite {
						writer.code('overwrite ')
					}
					ModifierKind.Private {
						writer.code('private ')
					}
					ModifierKind.Protected {
						writer.code('protected ')
					}
					ModifierKind.Public {
						writer.code('public ')
					}
					ModifierKind.Static {
						writer.code('static ')
					}
				}
			}
		}

		header(writer)

		if ?data.name {
			writer.expression(data.name)
		}

		if ?data.typeParameters {
			toTypeParameters(data.typeParameters, writer)
		}

		if ?data.parameters {
			writer.code('(')

			for var parameter, i in data.parameters {
				if i != 0 {
					writer.code(', ')
				}

				writer.expression(parameter)
			}

			writer.code(')')
		}

		if ?data.type {
			writer.code(': ').expression(data.type)
		}

		if data.throws?.length > 0 {
			writer.code(' ~ ')

			for var throw, index in data.throws {
				if index != 0 {
					writer.code(', ')
				}

				writer.expression(throw)
			}
		}
	} # }}}

	func toFunctionBody(modifiers, data, writer) { # {{{
		if data.kind == AstKind.Block {
			writer
				.newBlock()
				.expression(data)
				.done()
		}
		else if data.kind == AstKind.IfStatement {
			writer
				.code(' => ')
				.expression(data.whenTrue.value)
				.code(' if ')
				.expression(data.condition)

			if ?data.whenFalse {
				writer
					.code(' else ')
					.expression(data.whenFalse.value)
			}
		}
		else if data.kind == AstKind.ReturnStatement {
			writer.code(' => ').expression(data.value)
		}
		else {
			writer.code(' => ')

			if data.kind == AstKind.ObjectExpression {
				writer.code('(').expression(data).code(')')
			}
			else {
				writer.expression(data)
			}
		}
	} # }}}

	func toIfDeclaration(data, writer) { # {{{
		writer
			.expression(data[0])
			.code(' ;; ').expression(data[1]) if ?data[1]
	} # }}}

	func toImport(data, writer) {
		match data.kind {
			AstKind.NamedArgument, AstKind.PositionalArgument { # {{{
				for var modifier in data.modifiers {
					if modifier.kind == ModifierKind.Required {
						writer.code('require ')
					}
				}

				if ?data.name {
					writer.expression(data.name).code(': ')
				}

				writer.expression(data.value)
			} # }}}
			AstKind.GroupSpecifier { # {{{
				var mut alias = false
				var mut exclusion = false
				var mut wildcard = false

				for var modifier in data.modifiers {
					if modifier.kind == ModifierKind.Alias {
						alias = true
					}
					else if modifier.kind == ModifierKind.Exclusion {
						exclusion = true
					}
					else if modifier.kind == ModifierKind.Wildcard {
						wildcard = true
					}
				}

				if alias {
					writer.code(' => ')

					for var element, index in data.elements {
						if index > 0 {
							writer.code(', ')
						}

						writer.expression(element)
					}
				}
				else if exclusion {
					writer.code(' but ')

					for var element, index in data.elements {
						if index > 0 {
							writer.code(', ')
						}

						writer.expression(element)
					}
				}
				else if wildcard {
					writer.code(' for *')
				}
				else {
					writer.code(' for')

					var block = writer.newBlock()

					for var element in data.elements {
						block.newLine().expression(element).done()
					}

					block.done()
				}
			} # }}}
			AstKind.ImportDeclarator { # {{{
				writer.expression(data.source)

				var mut autofill = false

				for var modifier in data.modifiers {
					if modifier.kind == ModifierKind.Autofill {
						autofill = true
					}
				}

				if ?#data.arguments {
					writer.code('(')

					for var argument, index in data.arguments {
						if index != 0 {
							writer.code(', ')
						}

						writer.expression(argument)
					}

					writer.code(')')
				}
				else if autofill {
					writer.code('(...)')
				}

				if ?data.type {
					if data.type.kind == AstKind.ClassDeclaration {
						var block = writer.newBlock()

						block.newLine().expression(data.type).done()

						block.done()
					}
					else {
						writer.expression(data.type)
					}
				}

				if data.specifiers.length == 1 {
					var specifier = data.specifiers[0]

					if specifier.kind == AstKind.GroupSpecifier {
						writer.expression(specifier)
					}
					else {
						writer.code(' for ').expression(specifier)
					}
				}
				else if ?#data.specifiers {
					writer.code(' for')

					var block = writer.newBlock()

					for var specifier in data.specifiers {
						block.newLine().expression(specifier).done()
					}

					block.done()
				}
			} # }}}
			AstKind.NamedSpecifier { # {{{
				if ?data.external {
					writer.expression(data.external).code(` => \(data.internal.name)`)
				}
				else {
					writer.expression(data.internal)
				}
			} # }}}
			AstKind.TypeList { # {{{
				var block = writer.newBlock()

				for var type in data.types {
					toAttributes(type, AttributeMode.Outer, block)

					block.newLine().expression(type).done()
				}

				block.done()
			} # }}}
			AstKind.TypedSpecifier { # {{{
				writer.statement(data.type)
			} # }}}
			else { # {{{
				toExpression(data, ExpressionMode.Top, writer)
			} # }}}
		}
	}

	func toIteration(data, writer) { # {{{
		var mut declarative = false
		var mut mutable = false

		match data.kind {
			IterationKind.Array {
				var mut descending = false

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Declarative {
							declarative = true
						}
						ModifierKind.Descending {
							descending = true
						}
						ModifierKind.Mutable {
							mutable = true
						}
					}
				}

				if declarative {
					toAttributes(data, AttributeMode.Inline, writer)

					writer
						..code('var ')
						..code('mut ') if mutable
				}

				if ?data.value {
					writer.expression(data.value)

					if ?data.type {
						writer.code(': ').expression(data.type)
					}

					if ?data.index {
						writer.code(', ').expression(data.index)
					}
				}
				else {
					writer.code('_, ').expression(data.index)
				}

				writer.code(' in ').expression(data.expression)

				if ?data.from {
					writer.code(' from ').expression(data.from)
				}

				if descending {
					writer.code(' down')
				}

				if ?data.to {
					if hasModifier(data.to, ModifierKind.Ballpark) {
						writer.code(' to~ ').expression(data.to)
					}
					else {
						writer.code(' to ').expression(data.to)
					}
				}

				if ?data.step {
					writer.code(' step ').expression(data.step)
				}

				if ?data.split {
					writer.code(' split ').expression(data.split)
				}

				if ?data.until {
					writer.code(' until ').expression(data.until)
				}
				else if ?data.while {
					writer.code(' while ').expression(data.while)
				}

				if ?data.when {
					writer.code(' when ').expression(data.when)
				}
			}
			IterationKind.From {
				var mut ascending = false
				var mut descending = false

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Ascending {
							ascending = true
						}
						ModifierKind.Declarative {
							declarative = true
						}
						ModifierKind.Descending {
							descending = true
						}
						ModifierKind.Mutable {
							mutable = true
						}
					}
				}

				if declarative {
					toAttributes(data, AttributeMode.Inline, writer)

					writer
						..code('var ')
						..code('mut ') if mutable
				}

				writer.expression(data.variable)

				if hasModifier(data.from, ModifierKind.Ballpark) {
					writer.code(' from~ ').expression(data.from)
				}
				else {
					writer.code(' from ').expression(data.from)
				}

				if ascending {
					writer.code(' up')
				}
				else if descending {
					writer.code(' down')
				}

				if hasModifier(data.to, ModifierKind.Ballpark) {
					writer.code(' to~ ').expression(data.to)
				}
				else {
					writer.code(' to ').expression(data.to)
				}

				if ?data.step {
					writer.code(' step ').expression(data.step)
				}

				if ?data.until {
					writer.code(' until ').expression(data.until)
				}
				else if ?data.while {
					writer.code(' while ').expression(data.while)
				}

				if ?data.when {
					writer.code(' when ').expression(data.when)
				}
			}
			IterationKind.Object {
				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Declarative {
							declarative = true
						}
						ModifierKind.Mutable {
							mutable = true
						}
					}
				}

				if declarative {
					toAttributes(data, AttributeMode.Inline, writer)

					writer
						..code('var ')
						..code('mut ') if mutable
				}

				if ?data.value {
					writer.expression(data.value)

					if ?data.type {
						writer.code(': ').expression(data.type)
					}

					if ?data.key {
						writer.code(', ').expression(data.key)
					}
				}
				else {
					writer.code('_, ').expression(data.key)
				}

				writer.code(' of ').expression(data.expression)

				if ?data.until {
					writer.code(' until ').expression(data.until)
				}
				else if ?data.while {
					writer.code(' while ').expression(data.while)
				}

				if ?data.when {
					writer.code(' when ').expression(data.when)
				}
			}
			IterationKind.Range {
				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Declarative {
							declarative = true
						}
						ModifierKind.Mutable {
							mutable = true
						}
					}
				}

				if declarative {
					toAttributes(data, AttributeMode.Inline, writer)

					writer
						..code('var ')
						..code('mut ') if mutable
				}

				writer
					.expression(data.value)
					.code(' in ')
					.expression(data.from)
					.code(if hasModifier(data.from, ModifierKind.Ballpark) set '<' else '')
					.code('..')
					.code(if hasModifier(data.to, ModifierKind.Ballpark) set '<' else '')
					.expression(data.to)

				if ?data.step {
					writer
						.code('..')
						.expression(data.step)
				}

				if ?data.until {
					writer.code(' until ').expression(data.until)
				}
				else if ?data.while {
					writer.code(' while ').expression(data.while)
				}

				if ?data.when {
					writer.code(' when ').expression(data.when)
				}
			}
		}
	} # }}}

	func toQuote(value) { # {{{
		return '"' + value.replace(/"/g, '\\"').replace(/\n/g, '\\n') + '"'
	} # }}}

	func toQuoteElements(elements, writer, parent? = null) { # {{{
		var last = elements.length - 1

		for var element, index in elements {
			match element.kind {
				QuoteElementKind.Escape {
					writer.code(`#\(element.value)`)
				}
				QuoteElementKind.Expression {
					writer.code('#')

					if !?#element.reifications {
						writer.code('(').expression(element.expression).code(')')
					}
					else if element.reifications[0].kind == ReificationKind.Join {
						writer.code('j')

						if #element.reifications == 2 {
							toReification(element.reifications[1], writer)

							writer.code('c')
						}

						writer.code('(').expression(element.expression).code(', ').expression(element.separator).code(')')
					}
					else {
						toReification(element.reifications[0], writer)

						if #element.reifications == 2 {
							toReification(element.reifications[1], writer)
						}

						writer.code('(').expression(element.expression).code(')')
					}
				}
				QuoteElementKind.Literal {
					writer.code(element.value)
				}
				QuoteElementKind.NewLine {
					if index != 0 && index != last && elements[index - 1].kind != QuoteElementKind.NewLine {
						parent.newLine()
					}
				}
			}
		}
	} # }}}

	func toReification(data, writer) { # {{{
		match data.kind {
			ReificationKind.Argument {
				writer.code('a')
			}
			ReificationKind.Block {
				writer.code('b')
			}
			ReificationKind.Code {
				writer.code('c')
			}
			ReificationKind.Identifier {
				writer.code('i')
			}
			ReificationKind.Value {
				writer.code('v')
			}
		}
	} # }}}

	func toType(data, writer) { # {{{
		if ?data.type {
			writer.code(': ').expression(data.type)
		}
		else {
			for var modifier in data.modifiers {
				match modifier.kind {
					ModifierKind.Nullable {
						writer.code('?')
					}
				}
			}
		}
	} # }}}

	func toTypeParameters(data, writer) { # {{{
		writer.code('<')


		for var parameter, index in data {
			if index != 0 {
				writer.code(', ')
			}

			writer.expression(parameter)
		}

		writer.code('>')
	} # }}}

	func toStatement(data: Ast, writer) {
		match data {
			.AccessorDeclaration { # {{{
				var line = writer
					.newLine()
					.code('get')

				if ?data.body {
					if data.body.kind == AstKind.Block {
						line.newBlock().expression(data.body).done()
					}
					else {
						line.code(' => ').expression(data.body)
					}
				}

				line.done()
			} # }}}
			.BitmaskDeclaration { # {{{
				var line = writer.newLine()

				line.code('bitmask ').expression(data.name)

				if ?data.type {
					line.code('<').expression(data.type).code('>')
				}

				var block = line.newBlock()

				for var member in data.members {
					block.statement(member)
				}

				block.done()
				line.done()
			} # }}}
			.BitmaskValue { # {{{
				var line = writer.newLine()

				line.expression(data.name)

				if ?data.value {
					line.code(' = ').expression(data.value)
				}

				line.done()
			} # }}}
			.BlockStatement { # {{{
				writer
					.newControl()
					.code('block ')
					.expression(data.label)
					.step()
					.expression(data.body)
					.done()
			} # }}}
			.BreakStatement { # {{{
				var line = writer
					.newLine()
					.code('break')

				if ?data.label {
					line.code(' ').expression(data.label)
				}

				line.done()
			} # }}}
			.CatchClause { # {{{
				if ?data.type {
					writer
						.code('on ')
						.expression(data.type)

					if ?data.binding {
						writer
							.code(' catch ')
							.expression(data.binding)
					}
				}
				else {
					writer.code('catch')

					if ?data.binding {
						writer
							.code(' ')
							.expression(data.binding)
					}
				}

				writer
					.step()
					.expression(data.body)
			} # }}}
			.ClassDeclaration { # {{{
				var line = writer.newLine()

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Abstract {
							line.code('abstract ')
						}
						ModifierKind.Final {
							line.code('final ')
						}
						ModifierKind.Sealed {
							line.code('sealed ')
						}
						ModifierKind.System {
							line.code('system ')
						}
					}
				}

				line.code('class ').expression(data.name)

				if ?data.typeParameters {
					toTypeParameters(data.typeParameters, line)
				}

				if ?data.version {
					line.code(`@\(data.version.major).\(data.version.minor).\(data.version.patch)`)
				}

				if ?data.extends {
					line.code(' extends ').expression(data.extends)
				}

				if ?#data.implements {
					line.code(' implements ')

					for var implement, index in data.implements {
						line.code(', ') if index > 0

						line.expression(implement)
					}
				}

				var block = line.newBlock()

				for var member in data.members {
					block.statement(member)
				}

				block.done()

				line.done()
			} # }}}
			.ContinueStatement { # {{{
				var line = writer
					.newLine()
					.code('continue')

				if ?data.label {
					line.code(' ').expression(data.label)
				}

				line.done()
			} # }}}
			.DiscloseDeclaration { # {{{
				var line = writer
					.newLine()
					.code('disclose ')
					.expression(data.name)

				if ?data.typeParameters {
					toTypeParameters(data.typeParameters, line)
				}

				var block = line.newBlock()

				for var member in data.members {
					block.statement(member)
				}

				block.done()
				line.done()
			} # }}}
			.DoUntilStatement { # {{{
				writer
					.newControl()
					.code('do')
					.step()
					.expression(data.body)
					.step()
					.code('until ')
					.expression(data.condition)
					.done()
			} # }}}
			.DoWhileStatement { # {{{
				writer
					.newControl()
					.code('do')
					.step()
					.expression(data.body)
					.step()
					.code('while ')
					.expression(data.condition)
					.done()
			} # }}}
			.EnumDeclaration { # {{{
				var line = writer.newLine()

				line.code('enum ').expression(data.name)

				if ?data.type {
					line
						.code('<').expression(data.type)
						.code(';').expression(data.initial) if ?data.initial
						.code(';').expression(data.step) if ?data.step
						.code('>')
				}

				var block = line.newBlock()


				for var member in data.members {
					block.statement(member)
				}

				block.done()
				line.done()
			} # }}}
			.EnumValue { # {{{
				var line = writer.newLine()

				line.expression(data.name)

				if ?data.arguments {
					line.code(' = (')

					for var argument, index in data.arguments {
						line
							..code(', ') if index != 0
							..expression(argument)
					}

					line.code(')')

					if ?data.value {
						line.code(' & ').expression(data.value)
					}
				}
				else if ?data.value {
					line.code(' = ').expression(data.value)
				}

				line.done()
			} # }}}
			.ExportDeclaration { # {{{
				var line = writer.newLine()

				line.pushMode(KSWriterMode.Export)

				if data.declarations.length == 1 && ((data.declarations[0] is .DeclarationSpecifier) -> (!?#data.declarations[0].declaration.attributes)) {
					line.code('export ').statement(data.declarations[0])
				}
				else {
					var block = line.code('export').newBlock()

					for var declaration in data.declarations {
						if declaration is .DeclarationSpecifier {
							block.statement(declaration.declaration)
						}
						else {
							block.newLine().expression(declaration).done()
						}
					}

					block.done()
				}

				line.popMode()

				line.done()
			} # }}}
			.ExpressionStatement { # {{{
				writer
					.newLine()
					.expression(data.expression, ExpressionMode.Top)
					.done()
			} # }}}
			.ExternDeclaration { # {{{
				var line = writer.newLine()

				if data.declarations.length == 1 {
					line.code('extern ').statement(data.declarations[0])
				}
				else {
					writer.pushMode(KSWriterMode.Extern)

					var block = line.code('extern').newBlock()

					for var declaration in data.declarations {
						block.statement(declaration)
					}

					block.done()

					writer.popMode()
				}

				line.done()
			} # }}}
			.ExternOrRequireDeclaration { # {{{
				var line = writer.newLine()

				if data.declarations.length == 1 && data.declarations[0].attributes.length == 0 {
					line.code('extern|require ').statement(data.declarations[0])
				}
				else {
					writer.pushMode(KSWriterMode.Extern)

					var block = line.code('extern|require').newBlock()

					for var declaration in data.declarations {
						block.statement(declaration)
					}

					block.done()

					writer.popMode()
				}

				line.done()
			} # }}}
			.ExternOrImportDeclaration { # {{{
				var line = writer.newLine()

				line.pushMode(KSWriterMode.Import)

				if data.declarations.length == 1 && data.declarations[0].attributes.length == 0 {
					line.code('extern|import ').expression(data.declarations[0])
				}
				else {
					var block = line.code('extern|import').newBlock()

					for var declaration in data.declarations {
						toAttributes(declaration, AttributeMode.Outer, block)

						block.newLine().expression(declaration).done()
					}

					block.done()
				}

				line.popMode()

				line.done()
			} # }}}
			.FallthroughStatement { # {{{
				writer.newLine().code('fallthrough').done()
			} # }}}
			.FieldDeclaration { # {{{
				var line = writer.newLine()

				var mut nullable = false

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Constant {
							line.code('const ')
						}
						ModifierKind.Dynamic {
							line.code('dyn ')
						}
						ModifierKind.Final {
							line.code('final ')
						}
						ModifierKind.Internal {
							line.code('internal ')
						}
						ModifierKind.LateInit {
							line.code('late ')
						}
						ModifierKind.Nullable {
							nullable = true
						}
						ModifierKind.Private {
							line.code('private ')
						}
						ModifierKind.Protected {
							line.code('protected ')
						}
						ModifierKind.Public {
							line.code('public ')
						}
						ModifierKind.Static {
							line.code('static ')
						}
					}
				}

				for var modifier in data.modifiers {
					if modifier.kind == ModifierKind.ThisAlias {
						line.code('@')

						break
					}
				}

				if data.type?.kind == AstKind.VariantType {
					line.code('variant ').expression(data.name).code(': ').expression(data.type.master)

					if ?#data.type.properties {
						var block = line.newBlock()

						for var property in data.type.properties {
							block.newLine().expression(property).done()
						}

						block.done()
					}
				}
				else {
					line.expression(data.name)

					line.code('?') if nullable

					if ?data.type {
						line.code(': ').expression(data.type)
					}

					if ?data.value {
						line.code(' = ').expression(data.value)
					}
				}

				line.done()
			} # }}}
			.ForStatement { # {{{
				if data.body.kind == AstKind.ExpressionStatement {
					var line = writer
						.newLine()
						.expression(data.body.expression)
						.code(' for ')

					toIteration(data.iterations[0], line)

					line.done()
				}
				else {
					var ctrl = writer
						.newControl()
						.code('for')

					if data.iterations.length == 1 {
						toIteration(data.iterations[0], ctrl.code(' '))
					}
					else {
						ctrl.step()

						for var iteration in data.iterations {
							ctrl.newLine().run(iteration, toIteration).done()
						}

						ctrl.step().code('then')
					}

					ctrl
						.step().expression(data.body)
						.step().code('else').step().expression(data.else) if ?data.else
						.done()
				}
			} # }}}
			.FunctionDeclaration { # {{{
				var line = writer.newLine()

				toFunctionHeader(data, writer => {
					// if writer.mode() == KSWriterMode.Syntime {
					// 	writer.code('macro ')
					// }
					// else {
						writer.code('func ')
					// }
				}, line)

				if ?data.body {
					toFunctionBody(data.modifiers, data.body, line)
				}

				line.done()
			} # }}}
			.IfStatement { # {{{
				match data.whenTrue {
					.Block {
						var ctrl = writer.newControl().code('if')

						if ?data.declarations {
							if data.declarations.length == 1 {
								toIfDeclaration(data.declarations[0], ctrl.code(' '))
							}
							else {
								ctrl.step()

								for var declaration in data.declarations {
									ctrl.newLine().run(declaration, toIfDeclaration).done()
								}

								ctrl.step().code('then')
							}
						}
						else if ?data.condition {
							ctrl.code(' ').expression(data.condition)
						}

						ctrl.step().expression(data.whenTrue)

						var mut stmt = data

						while ?stmt.whenFalse {
							if stmt.whenFalse is .IfStatement {
								stmt = stmt.whenFalse

								ctrl.step().code('else if ')

								if ?stmt.declarations {
									if stmt.declarations.length == 1 {
										toIfDeclaration(stmt.declarations[0], ctrl.code(' '))
									}
									else {
										ctrl.step()

										for var declaration in stmt.declarations {
											ctrl.newLine().run(declaration, toIfDeclaration).done()
										}

										ctrl.step().code('then')
									}
								}
								else if ?stmt.condition {
									ctrl.expression(stmt.condition)
								}

								ctrl.step().expression(stmt.whenTrue)
							}
							else {
								ctrl
									.step()
									.code('else')
									.step()
									.expression(stmt.whenFalse)

								break
							}
						}

						ctrl.done()
					}
					.BreakStatement {
						var line = writer
							.newLine()
							.code('break ')

						if ?data.whenTrue.label {
							line.expression(data.whenTrue.label).code(' ')
						}

						line
							.code('if ')
							.expression(data.condition)
							.done()
					}
					.ContinueStatement {
						var line = writer
							.newLine()
							.code('continue ')

						if ?data.whenTrue.label {
							line.expression(data.whenTrue.label).code(' ')
						}

						line
							.code('if ')
							.expression(data.condition)
							.done()
					}
					.ExpressionStatement {
						writer
							.newLine()
							.expression(data.whenTrue.expression)
							.code(' if ')
							.expression(data.condition)
							.done()
					}
					.ReturnStatement {
						if ?data.whenTrue.value {
							writer
								.newLine()
								.code('return ')
								.expression(data.whenTrue.value)
								.code(' if ')
								.expression(data.condition)
								.done()
						}
						else {
							writer
								.newLine()
								.code('return if ')
								.expression(data.condition)
								.done()
						}
					}
					.ThrowStatement {
						writer
							.newLine()
							.code('throw ')
							.expression(data.whenTrue.value)
							.code(' if ')
							.expression(data.condition)
							.done()
					}
				}
			} # }}}
			.ImplementDeclaration { # {{{
				var line = writer
					.newLine()
					.code('impl ')

				if ?data.interface {
					line.expression(data.interface).code(' for ')
				}

				line.expression(data.variable)

				var block = line.newBlock()

				for var property in data.properties {
					block.statement(property)
				}

				block.done()
				line.done()
			} # }}}
			.ImportDeclaration { # {{{
				var line = writer.newLine()

				line.pushMode(KSWriterMode.Import)

				if data.declarations.length == 1 && !?#data.declarations[0].attributes {
					line.code('import ').expression(data.declarations[0])
				}
				else {
					var block = line.code('import').newBlock()

					for var declaration in data.declarations {
						toAttributes(declaration, AttributeMode.Outer, block)

						block.newLine().expression(declaration).done()
					}

					block.done()
				}

				line.popMode()

				line.done()
			} # }}}
			.IncludeAgainDeclaration { # {{{
				var line = writer.newLine()

				if data.declarations.length == 1 {
					line.code('include again ').statement(data.declarations[0])
				}
				else {
					var block = line.code('include again').newBlock()

					for var declaration in data.declarations {
						block.newLine().statement(declaration).done()
					}

					block.done()
				}

				line.done()
			} # }}}
			.IncludeDeclaration { # {{{
				var line = writer.newLine()

				var block = line.code('include').newBlock()

				for var declaration in data.declarations {
					block.expression(declaration)
				}

				block.done()

				line.done()
			} # }}}
			.MacroDeclaration { # {{{
				var line = writer.newLine()

				toFunctionHeader(data, writer => {
					writer.code('macro ')
				}, line)

				toFunctionBody(data.modifiers, data.body, line)

				line.done()
			} # }}}
			.MatchClause { # {{{
				var line = writer.newLine()

				var mut space = false

				if ?#data.conditions {
					for var condition, index in data.conditions {
						if index != 0 {
							line.code(', ')
						}

						line.expression(condition)
					}

					space = true
				}

				if ?data.binding {
					line
						.code(' ') if space
						.code('with ')
						.expression(data.binding)

					space = true
				}

				if ?data.filter {
					line.code(' ') if space

					line
						.code('when ')
						.expression(data.filter)

					space = true
				}

				if !space {
					line.code('else')
				}

				match data.body {
					.Block {
						line
							.newBlock()
							.expression(data.body)
							.done()
					}
					.ExpressionStatement {
						line
							.code(' => ')
							.expression(data.body.expression)
					}
					.SetStatement {
						line
							.code(' => ')
							.expression(data.body.value)
					}
					else {
						line
							.code(' => ')
							.statement(data.body)
					}
				}

				line.done()
			} # }}}
			.MatchStatement { # {{{
				var ctrl = writer
					.newControl()
					.code('match ')
					.expression(if ?data.declaration set data.declaration else data.expression)
					.step()

				for var clause in data.clauses {
					ctrl.statement(clause)
				}

				ctrl.done()
			} # }}}
			.MethodDeclaration { # {{{
				var line = writer.newLine()

				toFunctionHeader(data, writer => {}, line)

				if ?data.body {
					toFunctionBody(data.modifiers, data.body, line)
				}

				line.done()
			} # }}}
			.Module { # {{{
				toAttributes(data, AttributeMode.Inner, writer)

				for var node in data.body {
					writer.statement(node)
				}
			} # }}}
			.MutatorDeclaration { # {{{
				var line = writer
					.newLine()
					.code('set')

				if ?data.body {
					if data.body.kind == AstKind.Block {
						line.newBlock().expression(data.body).done()
					}
					else {
						line.code(' => ').expression(data.body)
					}
				}

				line.done()
			} # }}}
			.NamespaceDeclaration { # {{{
				var line = writer.newLine()

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Sealed {
							line.code('sealed ')
						}
					}
				}

				line.code('namespace ').expression(data.name)

				if data.statements.length != 0 {
					var block = line.newBlock()

					for var statement in data.statements {
						block.statement(statement)
					}

					block.done()
				}

				line.done()
			} # }}}
			.PassStatement { # {{{
				writer.newLine().code('pass').done()
			} # }}}
			.PropertyDeclaration { # {{{
				var line = writer.newLine()

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Private {
							line.code('private ')
						}
						ModifierKind.Protected {
							line.code('protected ')
						}
						ModifierKind.Public {
							line.code('public ')
						}
					}
				}

				line.expression(data.name)

				if ?data.type {
					line.code(': ').expression(data.type)
				}

				var block = line.newBlock()

				if ?data.accessor {
					block.statement(data.accessor)
				}

				if ?data.mutator {
					block.statement(data.mutator)
				}

				block.done()

				if ?data.defaultValue {
					line.code(' = ')

					line.expression(data.defaultValue)
				}

				line.done()
			} # }}}
			.ProxyDeclaration { # {{{
				var line = writer.newLine()

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Private {
							line.code('private ')
						}
						ModifierKind.Protected {
							line.code('protected ')
						}
						ModifierKind.Public {
							line.code('public ')
						}
						ModifierKind.Static {
							line.code('static ')
						}
					}
				}

				line.code('proxy ')

				line.expression(data.internal)

				line.code(' = ')

				line.expression(data.external)

				line.done()
			} # }}}
			.ProxyGroupDeclaration { # {{{
				var line = writer.newLine()

				for var modifier in data.modifiers {
					match modifier {
						.Private {
							line.code('private ')
						}
						.Protected {
							line.code('protected ')
						}
						.Public {
							line.code('public ')
						}
						.Static {
							line.code('static ')
						}
					}
				}

				line.code('proxy ').expression(data.recipient)

				var block = line.newBlock()

				for var element in data.elements {
					var eLine = block.newLine()

					eLine.expression(element.external)

					// TODO!
					// if element.internal != element.external && element.internal.name != element.external.?name {
					if element.internal != element.external && (element.external is .Identifier -> element.internal.name != element.external.name) {
						eLine
							..code(' => ')
							..expression(element.internal)
					}

					eLine.done()
				}

				block.done()

				line.done()
			} # }}}
			.RepeatStatement { # {{{
				if data.body.kind == AstKind.Block {
					var ctrl = writer
						.newControl()
						.code('repeat')

					if ?data.expression {
						ctrl.code(' ').expression(data.expression).code(' times')
					}

					ctrl.step().expression(data.body).done()
				}
				else if data.body.kind == AstKind.ExpressionStatement {
					writer
						.newLine()
						.expression(data.body.expression)
						.code(' repeat ')
						.expression(data.expression)
						.code(' times')
						.done()
				}
			} # }}}
			.RequireDeclaration { # {{{
				var line = writer.newLine()

				if data.declarations.length == 1 && data.declarations[0].attributes.length == 0 {
					line.code('require ').statement(data.declarations[0])
				}
				else {
					writer.pushMode(KSWriterMode.Extern)

					var block = line.code('require').newBlock()

					for var declaration in data.declarations {
						block.statement(declaration)
					}

					block.done()

					writer.popMode()
				}

				line.done()
			} # }}}
			.RequireOrExternDeclaration { # {{{
				var line = writer.newLine()

				if data.declarations.length == 1 && data.declarations[0].attributes.length == 0 {
					line.code('require|extern ').statement(data.declarations[0])
				}
				else {
					writer.pushMode(KSWriterMode.Extern)

					var block = line.code('require|extern').newBlock()

					for var declaration in data.declarations {
						block.statement(declaration)
					}

					block.done()

					writer.popMode()
				}

				line.done()
			} # }}}
			.RequireOrImportDeclaration { # {{{
				var line = writer.newLine()

				line.pushMode(KSWriterMode.Import)

				if data.declarations.length == 1 && data.declarations[0].attributes.length == 0 {
					line.code('require|import ').expression(data.declarations[0])
				}
				else {
					var block = line.code('require|import').newBlock()

					for var declaration in data.declarations {
						toAttributes(declaration, AttributeMode.Outer, block)

						block.newLine().expression(declaration).done()
					}

					block.done()
				}

				line.popMode()

				line.done()
			} # }}}
			.ReturnStatement { # {{{
				if ?data.value {
					writer
						.newLine()
						.code('return ')
						.expression(data.value)
						.done()
				}
				else {
					writer
						.newLine()
						.code('return')
						.done()
				}
			} # }}}
			.SemtimeStatement { # {{{
				var line = writer.newLine().code('semtime')

				if data.body.kind == AstKind.Block {
					line
						.newBlock()
						.expression(data.body)
						.done()
				}
				else {
					line.code(' ').expression(data.body)
				}

				line.done()
			} # }}}
			.SetStatement { # {{{
				writer
					.newLine()
					.code('set ')
					.expression(data.value)
					.done()
			} # }}}
			.ShebangDeclaration { # {{{
				writer.line(`#!\(data.command)`)
			} # }}}
			.StatementList { # {{{
				toAttributes(data, AttributeMode.Inner, writer)

				for var node in data.body {
					writer.statement(node)
				}
			} # }}}
			.StructDeclaration { # {{{
				var line = writer.newLine()

				line.code('struct ').expression(data.name)

				if ?data.extends {
					line.code(' extends ').expression(data.extends)
				}

				if ?#data.implements {
					line.code(' implements ')

					for var implement, index in data.implements {
						line.code(', ') if index > 0

						line.expression(implement)
					}
				}

				if data.fields.length != 0 {
					var block = line.newBlock()

					for var field in data.fields {
						block.statement(field)
					}

					block.done()
				}

				line.done()
			} # }}}
			.SyntimeDeclaration { # {{{
				// if writer.mode() == KSWriterMode.Syntime {
				// 	for var declaration in data.declarations {
				// 		writer.statement(declaration)
				// 	}
				// }
				// else {
					var line = writer.newLine()

					// line.pushMode(KSWriterMode.Syntime)

					if #data.declarations == 1 {
						line.code('syntime ').statement(data.declarations[0])
					}
					else {
						line.code('syntime')

						var block = line.newBlock()

						for var declaration in data.declarations {
							block.statement(declaration)
						}

						block.done()
					}

					line
						// ..popMode()
						..done()
				// }
			} # }}}
			.SyntimeStatement { # {{{
				toAttributes(data, AttributeMode.Inner, writer)

				// writer.pushMode(KSWriterMode.Syntime)

				writer.newControl().code('syntime do').step().expression(data.body).done()

				// writer.popMode()
			} # }}}
			.ThrowStatement { # {{{
				writer
					.newLine()
					.code('throw ')
					.expression(data.value)
					.done()
			} # }}}
			.TryStatement { # {{{
				var ctrl = writer
					.newControl()
					.code('try')
					.step()
					.expression(data.body)

				for var clause in data.catchClauses {
					ctrl
						.step()
						.statement(clause)
				}

				if ?data.catchClause {
					ctrl
						.step()
						.statement(data.catchClause)
				}

				if ?data.finalizer {
					ctrl
						.step()
						.code('finally')
						.step()
						.expression(data.finalizer)
				}

				ctrl.done()
			} # }}}
			.TupleDeclaration { # {{{
				var line = writer.newLine()

				line.code('tuple ').expression(data.name)

				if ?data.extends {
					line.code(' extends ').expression(data.extends)
				}

				if ?#data.implements {
					line.code(' implements ')

					for var implement, index in data.implements {
						line.code(', ') if index > 0

						line.expression(implement)
					}
				}

				if data.fields.length != 0 {
					var block = line.newBlock(null, SourceGeneration.BlockDelimiter.SQUARE_BRACKET)

					for var field in data.fields {
						block.newLine().statement(field).done()
					}

					block.done()
				}

				line.done()
			} # }}}
			.TupleField { # {{{
				if ?data.name {
					writer.expression(data.name)

					toType(data, writer)
				}
				else {
					writer.code(':').expression(data.type)
				}

				if ?data.defaultValue {
					writer.code(' = ').expression(data.defaultValue)
				}
			} # }}}
			.TypeAliasDeclaration { # {{{
				var line = writer
					.newLine()
					.code('type ')
					.expression(data.name)

				if ?data.typeParameters {
					toTypeParameters(data.typeParameters, line)
				}

				line
					.code(' = ')
					.expression(data.type)
					.done()
			} # }}}
			.UnlessStatement { # {{{
				match data.whenFalse {
					.Block {
						var ctrl = writer
							.newControl()
							.code('unless ')
							.expression(data.condition)
							.step()
							.expression(data.whenFalse)

						ctrl.done()
					}
					.BreakStatement {
						var line = writer
							.newLine()
							.code('break ')

						if ?data.whenFalse.label {
							line.expression(data.whenFalse.label).code(' ')
						}

						line
							.code('unless ')
							.expression(data.condition)
							.done()
					}
					.ContinueStatement {
						var line = writer
							.newLine()
							.code('continue ')

						if ?data.whenFalse.label {
							line.expression(data.whenFalse.label).code(' ')
						}

						line
							.code('unless ')
							.expression(data.condition)
							.done()
					}
					.ExpressionStatement {
						writer
							.newLine()
							.expression(data.whenFalse.expression)
							.code(' unless ')
							.expression(data.condition)
							.done()
					}
					.ReturnStatement {
						if ?data.whenFalse.value {
							writer
								.newLine()
								.code('return ')
								.expression(data.whenFalse.value)
								.code(' unless ')
								.expression(data.condition)
								.done()
						}
						else {
							writer
								.newLine()
								.code('return unless ')
								.expression(data.condition)
								.done()
						}
					}
					.ThrowStatement {
						writer
							.newLine()
							.code('throw ')
							.expression(data.whenFalse.value)
							.code(' unless ')
							.expression(data.condition)
							.done()
					}
				}
			} # }}}
			.UntilStatement { # {{{
				writer
					.newControl()
					.code('until ')
					.expression(data.condition)
					.step()
					.expression(data.body)
					.done()
			} # }}}
			.VariableStatement { # {{{
				var line = writer.newLine()
				var mut declare = false

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Constant {
							line.code('const')

							declare = true
						}
						ModifierKind.Dynamic {
							line.code('var dyn')

							declare = true
						}
						ModifierKind.LateInit {
							line.code('var late')

							declare = true
						}
						ModifierKind.Mutable {
							line.code('var mut')

							declare = true
						}
					}
				}

				if !declare {
					line.code('var')
				}

				if data.declarations.length == 1 {
					line.code(' ').expression(data.declarations[0])
				}
				else {
					var block = line.newBlock()

					for var declaration in data.declarations {
						block.newLine().expression(declaration).done()
					}

					block.done()
				}

				line.done()
			} # }}}
			.VariantDeclaration { # {{{
				var line = writer.newLine()

				line.code('variant ').expression(data.name)

				if data.fields.length != 0 {
					var block = line.newBlock()

					for var field in data.fields {
						block.newLine().expression(field).done()
					}

					block.done()
				}

				line.done()
			} # }}}
			.WhileStatement { # {{{
				writer
					.newControl()
					.code('while ')
					.expression(data.condition)
					.step()
					.expression(data.body)
					.done()
			} # }}}
			.WithStatement { # {{{
				var ctrl = writer.newControl().code('with')

				if #data.variables == 1 {
					ctrl.code(' ').expression(data.variables[0]).step()

				}
				else {
					ctrl.step()

					for var variable in data.variables {
						ctrl.newLine().expression(variable).done()
					}

					ctrl.step().code('then').step()
				}

				ctrl.expression(data.body)

				if ?data.finalizer {
					ctrl.step().code('finally').step().expression(data.finalizer)
				}

				ctrl.done()
			} # }}}
			else { # {{{
				writer
					.newLine()
					.expression(data)
					.done()
			} # }}}
		}
	}

	func toWrap(data, writer) {
		match data.kind {
			AstKind.BinaryExpression when data.operator.kind != OperatorKind.TypeAssertion & OperatorKind.TypeCasting & OperatorKind.TypeSignalment { # {{{
				writer
					.code('(')
					.expression(data)
					.code(')')
			} # }}}
			AstKind.ComparisonExpression, AstKind.PolyadicExpression { # {{{
				writer
					.code('(')
					.expression(data)
					.code(')')
			} # }}}
			else { # {{{
				writer.expression(data)
			} # }}}
		}
	}

	export generate, KSWriter, KSWriterMode
}

export {
	KSGeneration.generate
	Ast
}
