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

export namespace Generator {
	var AssignmentOperatorSymbol = {
		`\(AssignmentOperatorKind.Addition)`			: ' += '
		`\(AssignmentOperatorKind.BitwiseAnd)`			: ' +&= '
		`\(AssignmentOperatorKind.BitwiseLeftShift)`	: ' +<= '
		`\(AssignmentOperatorKind.BitwiseOr)`			: ' +|= '
		`\(AssignmentOperatorKind.BitwiseRightShift)`	: ' +>= '
		`\(AssignmentOperatorKind.BitwiseXor)`			: ' +^= '
		`\(AssignmentOperatorKind.Division)`			: ' /= '
		`\(AssignmentOperatorKind.Empty)`				: ' !?#= '
		`\(AssignmentOperatorKind.EmptyCoalescing)`		: ' ?##= '
		`\(AssignmentOperatorKind.Equals)`				: ' = '
		`\(AssignmentOperatorKind.Existential)`			: ' ?= '
		`\(AssignmentOperatorKind.LogicalAnd)`			: ' &&= '
		`\(AssignmentOperatorKind.LogicalOr)`			: ' ||= '
		`\(AssignmentOperatorKind.LogicalXor)`			: ' ^^= '
		`\(AssignmentOperatorKind.Modulo)`				: ' %= '
		`\(AssignmentOperatorKind.Multiplication)`		: ' *= '
		`\(AssignmentOperatorKind.NonEmpty)`			: ' ?#= '
		`\(AssignmentOperatorKind.NonExistential)`		: ' !?= '
		`\(AssignmentOperatorKind.NullCoalescing)`		: ' ??= '
		`\(AssignmentOperatorKind.Quotient)`			: ' /.= '
		`\(AssignmentOperatorKind.Return)`				: ' <- '
		`\(AssignmentOperatorKind.Subtraction)`			: ' -= '
	}

	var BinaryOperatorSymbol = {
		`\(BinaryOperatorKind.Addition)`			: ' + '
		`\(BinaryOperatorKind.BitwiseAnd)`			: ' +& '
		`\(BinaryOperatorKind.BitwiseLeftShift)`	: ' +< '
		`\(BinaryOperatorKind.BitwiseOr)`			: ' +| '
		`\(BinaryOperatorKind.BitwiseRightShift)`	: ' +> '
		`\(BinaryOperatorKind.BitwiseXor)`			: ' +^ '
		`\(BinaryOperatorKind.Division)`			: ' / '
		`\(BinaryOperatorKind.Equality)`			: ' == '
		`\(BinaryOperatorKind.EmptyCoalescing)`		: ' ?## '
		`\(BinaryOperatorKind.GreaterThan)`			: ' > '
		`\(BinaryOperatorKind.GreaterThanOrEqual)`	: ' >= '
		`\(BinaryOperatorKind.Inequality)`			: ' != '
		`\(BinaryOperatorKind.LessThan)`			: ' < '
		`\(BinaryOperatorKind.LessThanOrEqual)`		: ' <= '
		`\(BinaryOperatorKind.LogicalAnd)`			: ' && '
		`\(BinaryOperatorKind.LogicalImply)`		: ' -> '
		`\(BinaryOperatorKind.LogicalOr)`			: ' || '
		`\(BinaryOperatorKind.LogicalXor)`			: ' ^^ '
		`\(BinaryOperatorKind.Match)`				: ' ~~ '
		`\(BinaryOperatorKind.Mismatch)`			: ' !~ '
		`\(BinaryOperatorKind.Modulo)`				: ' % '
		`\(BinaryOperatorKind.Multiplication)`		: ' * '
		`\(BinaryOperatorKind.NullCoalescing)`		: ' ?? '
		`\(BinaryOperatorKind.Quotient)`			: ' /. '
		`\(BinaryOperatorKind.Subtraction)`			: ' - '
		`\(BinaryOperatorKind.TypeEquality)`		: ' is '
		`\(BinaryOperatorKind.TypeInequality)`		: ' is not '
	}

	var JunctionOperatorSymbol = {
		`\(BinaryOperatorKind.JunctionAnd)`			: ' & '
		`\(BinaryOperatorKind.JunctionOr)`			: ' | '
		`\(BinaryOperatorKind.JunctionXor)`			: ' ^ '
	}

	var UnaryPrefixOperatorSymbol = {
		`\(UnaryOperatorKind.BitwiseNegation)`		: '+^'
		`\(UnaryOperatorKind.Constant)`				: 'const '
		`\(UnaryOperatorKind.Existential)`			: '?'
		`\(UnaryOperatorKind.Implicit)`				: '.'
		`\(UnaryOperatorKind.LogicalNegation)`		: '!'
		`\(UnaryOperatorKind.Negative)`				: '-'
		`\(UnaryOperatorKind.NonEmpty)`				: '#'
		`\(UnaryOperatorKind.Spread)`				: '...'
	}

	enum KSWriterMode {
		Default
		Export
		Extern
		Import
		Property
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

	class KSWriter extends Writer {
		private {
			@mode: KSWriterMode
			@references: Function[]{}	= {}
			@stack: Array				= []
		}
		constructor(options? = null) { # {{{
			super(Object.merge({
				mode: KSWriterMode.Default
				classes: {
					block: KSBlockWriter
					control: KSControlWriter
					expression: KSExpressionWriter
					line: KSLineWriter
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

			@mode = @options.mode
		} # }}}
		filterExpression(data, writer = this) => @options.filters.expression(data, writer)
		filterStatement(data, writer = this) => @options.filters.statement(data, writer)
		getReference(name: String): Function? { # {{{
			if var functions ?#= @references[name] {
				return functions[0]
			}

			return null
		} # }}}
		mode() => @mode
		popMode() { # {{{
			@mode = @stack.pop()
		} # }}}
		popReference(name: String): Void { # {{{
			if var functions ?#= @references[name] {
				functions.shift()
			}
		} # }}}
		pushMode(mode: KSWriterMode) { # {{{
			@stack.push(@mode)

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

	class KSBlockWriter extends BlockWriter {
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

	class KSControlWriter extends ControlWriter {
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

	class KSExpressionWriter extends ExpressionWriter {
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
		transformExpression(data, writer = this) => @writer.transformExpression(data, this)
		wrap(data) { # {{{
			if !this.filterExpression(data) {
				toWrap(this.transformExpression(data), this)
			}

			return this
		} # }}}
	}

	class KSLineWriter extends LineWriter {
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

	class KSObjectWriter extends ObjectWriter {
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

	func isDifferentName(a, b): Boolean { # {{{
		match b.kind {
			NodeKind.Identifier {
				return a.name != b.name
			}
			NodeKind.ThisExpression {
				return a.name != b.name.name
			}
		}

		return true
	} # }}}

	func generate(data, options? = null) { # {{{
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
			.code(mode == AttributeMode.Inner ? '#![' : '#[')
			.expression(data.declaration)
			.code(']')
	} # }}}

	func toAttributes(data, mode: AttributeMode, writer) { # {{{
		if data.attributes?.length > 0 {
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

	func toExport(data, writer) {
		match data.kind {
			NodeKind.DeclarationSpecifier { # {{{
				writer.pushMode(KSWriterMode.Default)
				writer.statement(data.declaration)
				writer.popMode()
			} # }}}
			NodeKind.GroupSpecifier { # {{{
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
			NodeKind.NamedSpecifier { # {{{
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
			NodeKind.PropertiesSpecifier { # {{{
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
			NodeKind.ArrayBinding { # {{{
				writer.code('[')

				for var element, index in data.elements {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(element)
				}

				writer.code(']')
			} # }}}
			NodeKind.ArrayComprehension { # {{{
				writer
					.code('[')
					.expression(data.expression)
					.run(data.loop, toLoopHeader)
					.code(']')
			} # }}}
			NodeKind.ArrayExpression { # {{{
				writer.code('[')

				for var value, index in data.values {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(value)
				}

				writer.code(']')
			} # }}}
			NodeKind.ArrayRange { # {{{
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
			NodeKind.ArrayType { # {{{
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
					writer.expression(data.rest)

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
			NodeKind.AttributeExpression { # {{{
				writer.expression(data.name).code('(')

				for var argument, index in data.arguments {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(argument)
				}

				writer.code(')')
			} # }}}
			NodeKind.AttributeOperation { # {{{
				writer
					.expression(data.name)
					.code(' = ')
					.expression(data.value)
			} # }}}
			NodeKind.AwaitExpression { # {{{
				writer.code('await')

				writer.code(' ').expression(data.operation) if ?data.operation
			} # }}}
			NodeKind.BinaryExpression { # {{{
				if data.operator.kind == BinaryOperatorKind.TypeCasting {
					writer.code('(').expression(data.left)

					var mut nf = true

					for var modifier in data.operator.modifiers {
						if modifier.kind == ModifierKind.Forced {
							writer.code(' as! ')

							nf = false
						}
						else if modifier.kind == ModifierKind.Nullable {
							writer.code(' as? ')

							nf = false
						}
					}

					if nf {
						writer.code(' as ')
					}

					writer.expression(data.right).code(')')
				}
				else {
					writer.wrap(data.left)

					if data.operator.kind == BinaryOperatorKind.Assignment {
						writer.code(AssignmentOperatorSymbol[data.operator.assignment])

						if mode == .Rolling && data.right.kind == NodeKind.RollingExpression {
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
					else if data.operator.kind == BinaryOperatorKind.BackwardPipeline | BinaryOperatorKind.ForwardPipeline {
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

						if data.operator.kind == BinaryOperatorKind.BackwardPipeline {
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
					else {
						writer.code(BinaryOperatorSymbol[data.operator.kind])

						writer.wrap(data.right)
					}
			}
			} # }}}
			NodeKind.BindingElement { # {{{
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
			NodeKind.Block { # {{{
				toAttributes(data, AttributeMode.Inner, writer)

				for var statement in data.statements {
					writer.statement(statement)
				}
			} # }}}
			NodeKind.CallExpression { # {{{
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
			NodeKind.ClassDeclaration { # {{{
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
			} # }}}
			NodeKind.ComparisonExpression { # {{{
				for var value, i in data.values {
					if i % 2 == 0 {
						writer.wrap(value)
					}
					else {
						writer.code(BinaryOperatorSymbol[value.kind])
					}
				}
			} # }}}
			NodeKind.ComputedPropertyName { # {{{
				writer
					.code('[')
					.expression(data.expression)
					.code(']')
			} # }}}
			NodeKind.ConditionalExpression { # {{{
				writer
					.wrap(data.condition)
					.code(' ? ')
					.wrap(data.whenTrue)
					.code(' : ')
					.wrap(data.whenFalse)
			} # }}}
			NodeKind.CurryExpression { # {{{
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
			NodeKind.DisruptiveExpression { # {{{
				var simpleTop = mode == .Top && data.mainExpression.kind == NodeKind.Identifier

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
			NodeKind.ExclusionType { # {{{
				for var type, index in data.types {
					if index != 0 {
						writer.code(type.kind == NodeKind.FunctionExpression ? ' ^^ ' : ' ^ ')
					}

					writer.expression(type)
				}
			} # }}}
			NodeKind.FunctionDeclaration { # {{{
				toFunctionHeader(data, writer => writer.code('func '), writer)
			} # }}}
			NodeKind.FunctionExpression { # {{{
				toFunctionHeader(data, writer => {
					if writer.mode() == KSWriterMode.Type {
						header?(writer)
					}
					else {
						writer.code('func')
					}
				}, writer)

				if ?data.body {
					if data.body.kind == NodeKind.Block {
						writer.newBlock().expression(data.body).done()
					}
					else {
						writer.code(' => ').expression(data.body)
					}
				}
			} # }}}
			NodeKind.FusionType { # {{{
				for var type, index in data.types {
					if index != 0 {
						writer.code(type.kind == NodeKind.FunctionExpression ? ' && ' : ' & ')
					}

					writer.expression(type)
				}
			} # }}}
			NodeKind.Identifier { # {{{
				writer.code(data.name)
			} # }}}
			NodeKind.IfExpression { # {{{
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

				ctrl.step().expression(data.whenTrue)

				while ?data.whenFalse {
					if data.whenFalse.kind == NodeKind.IfStatement {
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

				ctrl.done()
			} # }}}
			NodeKind.IncludeDeclarator { # {{{
				toAttributes(data, AttributeMode.Outer, writer)

				writer.newLine().code(toQuote(data.file)).done()
			} # }}}
			NodeKind.JunctionExpression { # {{{
				var operator = JunctionOperatorSymbol[data.operator.kind]

				for var operand, i in data.operands {
					writer.code(operator) if i != 0

					writer.expression(operand)
				}
			} # }}}
			NodeKind.LambdaExpression { # {{{
				toFunctionHeader(data, writer => {}, writer)

				if data.body.kind == NodeKind.Block {
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
			NodeKind.Literal { # {{{
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
			NodeKind.MacroExpression { # {{{
				writer.code('macro ')

				if data.elements[0].start.line == data.elements[data.elements.length - 1].end.line {
					toMacroElements(data.elements, writer)
				}
				else {
					var o = writer.newObject()

					var dyn line = o.newLine()

					toMacroElements(data.elements, line, o)

					o.done()
				}
			} # }}}
			NodeKind.MatchConditionArray { # {{{
				writer.code('[')

				for var value, index in data.values {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(value)
				}

				writer.code(']')
			} # }}}
			NodeKind.MatchConditionObject { # {{{
				writer.code('{')

				for var property, index in data.properties {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(property)
				}

				writer.code('}')
			} # }}}
			NodeKind.MatchConditionRange { # {{{
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
			NodeKind.MatchConditionType { # {{{
				writer
					.code('is ')
					.expression(data.type)
			} # }}}
			NodeKind.MatchExpression { # {{{
				writer
					.code('match ')
					.expression(data.expression)

				var block = writer.newBlock()

				for var clause in data.clauses {
					block.statement(clause)
				}

				block.done()
			} # }}}
			NodeKind.MemberExpression { # {{{
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
			NodeKind.NamedArgument { # {{{
				writer.expression(data.name).code(': ').expression(data.value)
			} # }}}
			NodeKind.NumericExpression { # {{{
				writer.code(data.value)
			} # }}}
			NodeKind.ObjectBinding { # {{{
				writer.code('{')

				for var element, index in data.elements {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(element)
				}

				writer.code('}')
			} # }}}
			NodeKind.ObjectExpression { # {{{
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
			NodeKind.ObjectMember { # {{{
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
			NodeKind.ObjectType { # {{{
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
					writer.expression(data.rest)

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
			NodeKind.OmittedExpression { # {{{
				if data.spread {
					writer.code('...')
				}
				else {
					writer.code('_')
				}
			} # }}}
			NodeKind.Parameter { # {{{
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
					if only || !?data.internal || data.internal.kind != NodeKind.Identifier & NodeKind.ThisExpression {
						pass
					}
					else {
						writer.code('_ % ')
					}
				}
				else if !?data.internal || isDifferentName(data.external, data.internal) {
					writer.expression(data.external)

					writer.code(' % ')
				}

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.AutoEvaluate {
							writer.code('@')
						}
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
			NodeKind.PlaceholderArgument { # {{{
				var mut rest = false

				for var modifier in data.modifiers {
					if modifier.kind == ModifierKind.Rest {
						rest = true

						break
					}
				}

				writer.code(rest ? '...' : '^')

				if ?data.index {
					writer.code(data.index.value)
				}
			} # }}}
			NodeKind.PolyadicExpression { # {{{
				writer.wrap(data.operands[0])

				for var operand in data.operands from 1 {
					writer
						.code(BinaryOperatorSymbol[data.operator.kind])
						.wrap(operand)
				}
			} # }}}
			NodeKind.PositionalArgument { # {{{
				writer.code('\\').expression(data.value)
			} # }}}
			NodeKind.PropertyType { # {{{
				if ?data.name {
					if ?data.type {
						if data.type.kind == NodeKind.FunctionExpression {
							toExpression(data.type, ExpressionMode.Top, writer, writer => writer.expression(data.name))
						}
						else if data.type.kind == NodeKind.VariantType {
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
			NodeKind.Reference { # {{{
				if var reference ?= writer.getReference(data.name) {
					reference(writer)
				}
			} # }}}
			NodeKind.RegularExpression { # {{{
				writer.code(data.value)
			} # }}}
			NodeKind.RestrictiveExpression { # {{{
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
			NodeKind.RollingExpression { # {{{
				toAttributes(data, AttributeMode.Inner, writer)

				writer.expression(data.object)

				if data.modifiers.some((modifier, ...) => modifier.kind == ModifierKind.Nullable) {
					writer.code('?')
				}

				for var expression in data.expressions {
					writer.code('\n').newIndent().code('.').expression(expression, ExpressionMode.Rolling)
				}
			} # }}}
			NodeKind.SequenceExpression { # {{{
				writer.code('(')

				for var expression, index in data.expressions {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(expression)
				}

				writer.code(')')
			} # }}}
			NodeKind.ShorthandProperty { # {{{
				writer.expression(data.name)
			} # }}}
			NodeKind.SpreadExpression { # {{{
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
			NodeKind.TaggedTemplateExpression { # {{{
				writer.expression(data.tag).expression(data.template)
			} # }}}
			NodeKind.TemplateExpression { # {{{
				var dyn multiline = false

				for var modifier in data.modifiers {
					if modifier.kind == ModifierKind.MultiLine {
						multiline = true
					}
				}

				if multiline {
					writer.code('```\n').newIndent()

					for var element in data.elements {
						if element.kind == NodeKind.Literal {
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
						if element.kind == NodeKind.Literal {
							writer.code(element.value)
						}
						else {
							writer.code('\\(').expression(element).code(')')
						}
					}

					writer.code('`')
				}
			} # }}}
			NodeKind.TopicReference { # {{{
				for var { kind } in data.modifiers {
					if kind == ModifierKind.Spread {
						writer.code('...')

						return
					}
				}

				writer.code('_')
			} # }}}
			NodeKind.ThisExpression { # {{{
				writer.code('@').expression(data.name)
			} # }}}
			NodeKind.TryExpression { # {{{
				writer.code('try')

				if data.modifiers.some((modifier, ...) => modifier.kind == ModifierKind.Disabled) {
					writer.code('!')
				}

				writer.code(' ').expression(data.argument)

				if ?data.defaultValue {
					writer.code(' ~~ ').expression(data.defaultValue)
				}
			} # }}}
			NodeKind.TypeParameter { # {{{
				writer.expression(data.name)
			} # }}}
			NodeKind.TypeReference { # {{{
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

						for var subtype, index in data.typeSubtypes {
							if index != 0 {
								writer.code(', ')
							}

							writer.expression(subtype)
						}

						writer.code(')')
					}

					if data.modifiers.some((modifier, ...) => modifier.kind == ModifierKind.Nullable) {
						writer.code('?')
					}
				}
			} # }}}
			NodeKind.UnaryExpression { # {{{
				var mut nullable = false

				for var modifier in data.modifiers {
					match modifier.kind {
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
						UnaryOperatorKind.TypeFitting {
							writer.code(nullable ? '!?' : '!!')
						}
					}
				}
			} # }}}
			NodeKind.UnaryTypeExpression { # {{{
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
			NodeKind.UnionType { # {{{
				for var type, index in data.types {
					if index != 0 {
						writer.code(type.kind == NodeKind.FunctionExpression ? ' || ' : ' | ')
					}

					writer.expression(type)
				}
			} # }}}
			NodeKind.VariableDeclaration { # {{{
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
			NodeKind.VariableDeclarator { # {{{
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
			NodeKind.VariantField { # {{{
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
		if data.kind == NodeKind.Block {
			writer
				.newBlock()
				.expression(data)
				.done()
		}
		else if data.kind == NodeKind.IfStatement {
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
		else if data.kind == NodeKind.ReturnStatement {
			writer.code(' => ').expression(data.value)
		}
		else {
			var mut auto = false

			for var modifier in modifiers {
				if modifier.kind == ModifierKind.AutoType {
					auto = true
				}
			}

			if auto {
				writer.code(' :> ')
			}
			else {
				writer.code(' => ')
			}

			if data.kind == NodeKind.ObjectExpression {
				writer.code('(').expression(data).code(')')
			}
			else {
				writer.expression(data)
			}
		}
	} # }}}

	func toIfDeclaration(data, writer) { # {{{
		writer
			.expression(data.declaration)
			.code(' ;; ').expression(data.condition) if ?data.condition
	} # }}}

	func toImport(data, writer) {
		match data.kind {
			NodeKind.NamedArgument, NodeKind.PositionalArgument { # {{{
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
			NodeKind.GroupSpecifier { # {{{
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
			NodeKind.ImportDeclarator { # {{{
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
					if data.type.kind == NodeKind.ClassDeclaration {
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

					if specifier.kind == NodeKind.GroupSpecifier {
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
			NodeKind.NamedSpecifier { # {{{
				if ?data.external {
					writer.expression(data.external).code(` => \(data.internal.name)`)
				}
				else {
					writer.expression(data.internal)
				}
			} # }}}
			NodeKind.TypeList { # {{{
				var block = writer.newBlock()

				for var type in data.types {
					toAttributes(type, AttributeMode.Outer, block)

					block.newLine().expression(type).done()
				}

				block.done()
			} # }}}
			NodeKind.TypedSpecifier { # {{{
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
					writer
						..code('var ')
						..code('mut ') if mutable
				}

				writer
					.expression(data.value)
					.code(' in ')
					.expression(data.from)
					.code(hasModifier(data.from, ModifierKind.Ballpark) ? '<' : '')
					.code('..')
					.code(hasModifier(data.to, ModifierKind.Ballpark) ? '<' : '')
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

	func toLoopHeader(data, writer) { # {{{
		match data.kind {
			NodeKind.ForStatement {
				writer.code(' for ').run(data.iteration, toIteration)
			}
			NodeKind.RepeatStatement {
				writer.code(' repeat ').expression(data.expression).code(' times')
			}
		}
	} # }}}

	func toMacroElements(elements, writer, parent? = null) { # {{{
		var last = elements.length - 1

		for var element, index in elements {
			match element.kind {
				MacroElementKind.Expression {
					writer.code('#')

					if !?element.reification {
						writer.code('(').expression(element.expression).code(')')
					}
					else if element.reification.kind == ReificationKind.Join {
						writer.code('j(').expression(element.expression).code(', ').expression(element.separator).code(')')
					}
					else {
						match element.reification.kind {
							ReificationKind.Argument {
								writer.code('a')
							}
							ReificationKind.Expression {
								writer.code('e')
							}
							ReificationKind.Statement {
								writer.code('s')
							}
							ReificationKind.Write {
								writer.code('w')
							}
						}

						writer.code('(').expression(element.expression).code(')')
					}
				}
				MacroElementKind.Literal {
					writer.code(element.value)
				}
				MacroElementKind.NewLine {
					if index != 0 && index != last && elements[index - 1].kind != MacroElementKind.NewLine {
						parent.newLine()
					}
				}
			}
		}
	} # }}}

	func toQuote(value) { # {{{
		return '"' + value.replace(/"/g, '\\"').replace(/\n/g, '\\n') + '"'
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

	func toStatement(mut data, writer) {
		match data.kind {
			NodeKind.AccessorDeclaration { # {{{
				var line = writer
					.newLine()
					.code('get')

				if ?data.body {
					if data.body.kind == NodeKind.Block {
						line.newBlock().expression(data.body).done()
					}
					else {
						line.code(' => ').expression(data.body)
					}
				}

				line.done()
			} # }}}
			NodeKind.BitmaskDeclaration { # {{{
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
			NodeKind.BlockStatement { # {{{
				writer
					.newControl()
					.code('block ')
					.expression(data.label)
					.step()
					.expression(data.body)
					.done()
			} # }}}
			NodeKind.BreakStatement { # {{{
				var line = writer
					.newLine()
					.code('break')

				if ?data.label {
					line.code(' ').expression(data.label)
				}

				line.done()
			} # }}}
			NodeKind.CatchClause { # {{{
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
			NodeKind.ClassDeclaration { # {{{
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
			NodeKind.ContinueStatement { # {{{
				var line = writer
					.newLine()
					.code('continue')

				if ?data.label {
					line.code(' ').expression(data.label)
				}

				line.done()
			} # }}}
			NodeKind.DiscloseDeclaration { # {{{
				var line = writer
					.newLine()
					.code('disclose ')
					.expression(data.name)

				var block = line.newBlock()

				for var member in data.members {
					block.statement(member)
				}

				block.done()
				line.done()
			} # }}}
			NodeKind.DoUntilStatement { # {{{
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
			NodeKind.DoWhileStatement { # {{{
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
			NodeKind.EnumDeclaration { # {{{
				var line = writer.newLine()

				line.code('enum ').expression(data.name)

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
			NodeKind.ExportDeclaration { # {{{
				var line = writer.newLine()

				line.pushMode(KSWriterMode.Export)

				if data.declarations.length == 1 && ((data.declarations[0].kind == NodeKind.DeclarationSpecifier) -> (!?#data.declarations[0].declaration.attributes)) {
					line.code('export ').statement(data.declarations[0])
				}
				else {
					var block = line.code('export').newBlock()

					for var declaration in data.declarations {
						if declaration.kind == NodeKind.DeclarationSpecifier {
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
			NodeKind.ExpressionStatement { # {{{
				writer
					.newLine()
					.expression(data.expression, ExpressionMode.Top)
					.done()
			} # }}}
			NodeKind.ExternDeclaration { # {{{
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
			NodeKind.ExternOrRequireDeclaration { # {{{
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
			NodeKind.ExternOrImportDeclaration { # {{{
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
			NodeKind.FallthroughStatement { # {{{
				writer.newLine().code('fallthrough').done()
			} # }}}
			NodeKind.FieldDeclaration { # {{{
				var line = writer.newLine()

				var mut nullable = false

				for var modifier in data.modifiers {
					match modifier.kind {
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

				line.expression(data.name)

				line.code('?') if nullable

				if ?data.type {
					line.code(': ').expression(data.type)
				}

				if ?data.value {
					line.code(' = ').expression(data.value)
				}

				line.done()
			} # }}}
			NodeKind.ForStatement { # {{{
				if data.body.kind == NodeKind.ExpressionStatement {
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
			NodeKind.FunctionDeclaration { # {{{
				var line = writer.newLine()

				toFunctionHeader(data, writer => {
					writer.code('func ')
				}, line)

				if ?data.body {
					toFunctionBody(data.modifiers, data.body, line)
				}

				line.done()
			} # }}}
			NodeKind.IfStatement { # {{{
				match data.whenTrue.kind {
					NodeKind.Block {
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

						while ?data.whenFalse {
							if data.whenFalse.kind == NodeKind.IfStatement {
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

						ctrl.done()
					}
					NodeKind.BreakStatement {
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
					NodeKind.ContinueStatement {
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
					NodeKind.ExpressionStatement {
						writer
							.newLine()
							.expression(data.whenTrue.expression)
							.code(' if ')
							.expression(data.condition)
							.done()
					}
					NodeKind.ReturnStatement {
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
					NodeKind.ThrowStatement {
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
			NodeKind.ImplementDeclaration { # {{{
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
			NodeKind.ImportDeclaration { # {{{
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
			NodeKind.IncludeAgainDeclaration { # {{{
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
			NodeKind.IncludeDeclaration { # {{{
				var line = writer.newLine()

				var block = line.code('include').newBlock()

				for var declaration in data.declarations {
					block.expression(declaration)
				}

				block.done()

				line.done()
			} # }}}
			NodeKind.MacroDeclaration { # {{{
				var line = writer.newLine()

				toFunctionHeader(data, writer => {
					writer.code('macro ')
				}, line)

				if data.body.kind == NodeKind.ExpressionStatement && data.body.expression.kind == NodeKind.MacroExpression {
					line.code(' => ')

					toMacroElements(data.body.expression.elements, line)
				}
				else {
					line
						.newBlock()
						.expression(data.body)
						.done()
				}

				line.done()
			} # }}}
			NodeKind.MatchClause { # {{{
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

				match data.body.kind {
					NodeKind.Block {
						line
							.newBlock()
							.expression(data.body)
							.done()
					}
					NodeKind.ExpressionStatement {
						line
							.code(' => ')
							.expression(data.body.expression)
					}
					NodeKind.SetStatement {
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
			NodeKind.MatchStatement { # {{{
				var ctrl = writer
					.newControl()
					.code('match ')
					.expression(?data.declaration ? data.declaration : data.expression)
					.step()

				for var clause in data.clauses {
					ctrl.statement(clause)
				}

				ctrl.done()
			} # }}}
			NodeKind.MethodDeclaration { # {{{
				var line = writer.newLine()

				toFunctionHeader(data, writer => {}, line)

				if ?data.body {
					toFunctionBody(data.modifiers, data.body, line)
				}

				line.done()
			} # }}}
			NodeKind.Module { # {{{
				toAttributes(data, AttributeMode.Inner, writer)

				for var node in data.body {
					writer.statement(node)
				}
			} # }}}
			NodeKind.MutatorDeclaration { # {{{
				var line = writer
					.newLine()
					.code('set')

				if ?data.body {
					if data.body.kind == NodeKind.Block {
						line.newBlock().expression(data.body).done()
					}
					else {
						line.code(' => ').expression(data.body)
					}
				}

				line.done()
			} # }}}
			NodeKind.NamespaceDeclaration { # {{{
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
			NodeKind.PassStatement { # {{{
				writer.newLine().code('pass').done()
			} # }}}
			NodeKind.PropertyDeclaration { # {{{
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
			NodeKind.ProxyDeclaration { # {{{
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
			NodeKind.ProxyGroupDeclaration { # {{{
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

				line.code('proxy ').expression(data.recipient)

				var block = line.newBlock()

				for var element of data.elements {
					var line = block.newLine()

					line.expression(element.external)

					if element.internal != element.external && element.internal.name != element.external.name {
						line.code(' => ')

						line.expression(element.internal)
					}

					line.done()
				}

				block.done()

				line.done()
			} # }}}
			NodeKind.RepeatStatement { # {{{
				if data.body.kind == NodeKind.Block {
					var ctrl = writer
						.newControl()
						.code('repeat')

					if ?data.expression {
						ctrl.code(' ').expression(data.expression).code(' times')
					}

					ctrl.step().expression(data.body).done()
				}
				else if data.body.kind == NodeKind.ExpressionStatement {
					writer
						.newLine()
						.expression(data.body.expression)
						.code(' repeat ')
						.expression(data.expression)
						.code(' times')
						.done()
				}
			} # }}}
			NodeKind.RequireDeclaration { # {{{
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
			NodeKind.RequireOrExternDeclaration { # {{{
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
			NodeKind.RequireOrImportDeclaration { # {{{
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
			NodeKind.ReturnStatement { # {{{
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
			NodeKind.SetStatement { # {{{
				writer
					.newLine()
					.code('set ')
					.expression(data.value)
					.done()
			} # }}}
			NodeKind.ShebangDeclaration { # {{{
				writer.line(`#!\(data.command)`)
			} # }}}
			NodeKind.StructDeclaration { # {{{
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
			NodeKind.StructField { # {{{
				var line = writer.newLine()

				if data.type?.kind == NodeKind.VariantType {
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

					toType(data, line)

					if ?data.defaultValue {
						line.code(' = ').expression(data.defaultValue)
					}
				}

				line.done()
			} # }}}
			NodeKind.ThrowStatement { # {{{
				writer
					.newLine()
					.code('throw ')
					.expression(data.value)
					.done()
			} # }}}
			NodeKind.TryStatement { # {{{
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
			NodeKind.TupleDeclaration { # {{{
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
					var block = line.newBlock(null, BlockDelimiter.SQUARE_BRACKET)

					for var field in data.fields {
						block.newLine().statement(field).done()
					}

					block.done()
				}

				line.done()
			} # }}}
			NodeKind.TupleField { # {{{
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
			NodeKind.TypeAliasDeclaration { # {{{
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
			NodeKind.UnlessStatement { # {{{
				match data.whenFalse.kind {
					NodeKind.Block {
						var ctrl = writer
							.newControl()
							.code('unless ')
							.expression(data.condition)
							.step()
							.expression(data.whenFalse)

						ctrl.done()
					}
					NodeKind.BreakStatement {
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
					NodeKind.ContinueStatement {
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
					NodeKind.ExpressionStatement {
						writer
							.newLine()
							.expression(data.whenFalse.expression)
							.code(' unless ')
							.expression(data.condition)
							.done()
					}
					NodeKind.ReturnStatement {
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
					NodeKind.ThrowStatement {
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
			NodeKind.UntilStatement { # {{{
				writer
					.newControl()
					.code('until ')
					.expression(data.condition)
					.step()
					.expression(data.body)
					.done()
			} # }}}
			NodeKind.VariableStatement { # {{{
				var line = writer.newLine()
				var mut declaration = false

				for var modifier in data.modifiers {
					match modifier.kind {
						ModifierKind.Constant {
							line.code('const')

							declaration = true
						}
						ModifierKind.Dynamic {
							line.code('var dyn')

							declaration = true
						}
						ModifierKind.LateInit {
							line.code('var late')

							declaration = true
						}
						ModifierKind.Mutable {
							line.code('var mut')

							declaration = true
						}
					}
				}

				if !declaration {
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
			NodeKind.VariantDeclaration { # {{{
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
			NodeKind.WhileStatement { # {{{
				writer
					.newControl()
					.code('while ')
					.expression(data.condition)
					.step()
					.expression(data.body)
					.done()
			} # }}}
			NodeKind.WithStatement { # {{{
				var ctrl = writer.newControl().code('with')

				if data.variables.length == 1 {
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
			NodeKind.BinaryExpression when data.operator.kind != BinaryOperatorKind.TypeCasting { # {{{
				writer
					.code('(')
					.expression(data)
					.code(')')
			} # }}}
			NodeKind.ComparisonExpression, NodeKind.ConditionalExpression, NodeKind.PolyadicExpression { # {{{
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

export Generator.generate
