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
	'@kaoscript/ast'
	'@kaoscript/source-writer'
}

extern console

export namespace Generator {
	const AssignmentOperatorSymbol = {
		`\(AssignmentOperatorKind::Addition)`			: ' += '
		`\(AssignmentOperatorKind::BitwiseAnd)`			: ' &= '
		`\(AssignmentOperatorKind::BitwiseLeftShift)`	: ' <<= '
		`\(AssignmentOperatorKind::BitwiseOr)`			: ' |= '
		`\(AssignmentOperatorKind::BitwiseRightShift)`	: ' >>= '
		`\(AssignmentOperatorKind::BitwiseXor)`			: ' ^= '
		`\(AssignmentOperatorKind::Division)`			: ' /= '
		`\(AssignmentOperatorKind::Equality)`			: ' = '
		`\(AssignmentOperatorKind::Existential)`		: ' ?= '
		`\(AssignmentOperatorKind::Modulo)`				: ' %= '
		`\(AssignmentOperatorKind::Multiplication)`		: ' *= '
		`\(AssignmentOperatorKind::NonExistential)`		: ' !?= '
		`\(AssignmentOperatorKind::NullCoalescing)`		: ' ??= '
		`\(AssignmentOperatorKind::Quotient)`			: ' /.= '
		`\(AssignmentOperatorKind::Subtraction)`		: ' -= '
	}

	const BinaryOperatorSymbol = {
		`\(BinaryOperatorKind::Addition)`			: ' + '
		`\(BinaryOperatorKind::And)`				: ' && '
		`\(BinaryOperatorKind::BitwiseAnd)`			: ' & '
		`\(BinaryOperatorKind::BitwiseLeftShift)`	: ' << '
		`\(BinaryOperatorKind::BitwiseOr)`			: ' | '
		`\(BinaryOperatorKind::BitwiseRightShift)`	: ' >> '
		`\(BinaryOperatorKind::BitwiseXor)`			: ' ^ '
		`\(BinaryOperatorKind::Division)`			: ' / '
		`\(BinaryOperatorKind::Equality)`			: ' == '
		`\(BinaryOperatorKind::GreaterThan)`		: ' > '
		`\(BinaryOperatorKind::GreaterThanOrEqual)`	: ' >= '
		`\(BinaryOperatorKind::Imply)`				: ' -> '
		`\(BinaryOperatorKind::Inequality)`			: ' != '
		`\(BinaryOperatorKind::LessThan)`			: ' < '
		`\(BinaryOperatorKind::LessThanOrEqual)`	: ' <= '
		`\(BinaryOperatorKind::Match)`				: ' ~~ '
		`\(BinaryOperatorKind::Mismatch)`			: ' !~ '
		`\(BinaryOperatorKind::Modulo)`				: ' % '
		`\(BinaryOperatorKind::Multiplication)`		: ' * '
		`\(BinaryOperatorKind::NullCoalescing)`		: ' ?? '
		`\(BinaryOperatorKind::Or)`					: ' || '
		`\(BinaryOperatorKind::Quotient)`			: ' /. '
		`\(BinaryOperatorKind::Subtraction)`		: ' - '
		`\(BinaryOperatorKind::TypeEquality)`		: ' is '
		`\(BinaryOperatorKind::TypeInequality)`		: ' is not '
		`\(BinaryOperatorKind::Xor)`				: ' ^^ '
	}

	const JunctionOperatorSymbol = {
		`\(BinaryOperatorKind::And)`				: ' & '
		`\(BinaryOperatorKind::Or)`					: ' | '
		`\(BinaryOperatorKind::Xor)`				: ' ^ '
	}

	const UnaryPrefixOperatorSymbol = {
		`\(UnaryOperatorKind::BitwiseNot)`			: '~'
		`\(UnaryOperatorKind::DecrementPrefix)`		: '--'
		`\(UnaryOperatorKind::Existential)`			: '?'
		`\(UnaryOperatorKind::IncrementPrefix)`		: '++'
		`\(UnaryOperatorKind::Negation)`			: '!'
		`\(UnaryOperatorKind::Negative)`			: '-'
		`\(UnaryOperatorKind::Spread)`				: '...'
	}

	const UnaryPostfixOperatorSymbol = {
		`\(UnaryOperatorKind::DecrementPostfix)`	: '--'
		`\(UnaryOperatorKind::ForcedTypeCasting)`	: '!!'
		`\(UnaryOperatorKind::IncrementPostfix)`	: '++'
		`\(UnaryOperatorKind::NullableTypeCasting)`	: '!?'
	}

	enum KSWriterMode {
		Default
		Extern
		Property
	}

	func $nilFilter(...) { // {{{
		return false
	} // }}}

	func $nilTransformer(...args) { // {{{
		return args[0]
	} // }}}

	class KSWriter extends Writer {
		private {
			_mode: KSWriterMode
			_stack: Array			= []
		}
		constructor(options = null) { // {{{
			super(Dictionary.merge({
				mode: KSWriterMode::Default
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
		} // }}}
		filterExpression(data, writer = this) => @options.filters.expression(data, writer)
		filterStatement(data, writer = this) => @options.filters.statement(data, writer)
		mode() => @mode
		popMode() { // {{{
			@mode = @stack.pop()
		} // }}}
		pushMode(mode: KSWriterMode) { // {{{
			@stack.push(@mode)

			@mode = mode
		} // }}}
		statement(data) { // {{{
			if !this.filterStatement(data) {
				toAttributes(data, false, this)

				toStatement(this.transformStatement(data), this)
			}

			return this
		} // }}}
		toSource() { // {{{
			let source = ''

			for fragment in this.toArray() {
				source += fragment.code
			}

			if source.length != 0 {
				return source.substr(0, source.length - 1)
			}
			else {
				return source
			}
		} // }}}
		transformExpression(data, writer = this) => @options.transformers.expression(data, writer)
		transformStatement(data, writer = this) => @options.transformers.statement(data, writer)
	}

	class KSBlockWriter extends BlockWriter {
		expression(data) { // {{{
			if !this.filterExpression(data) {
				toExpression(this.transformExpression(data), this)
			}

			return this
		} // }}}
		filterExpression(data) => @writer.filterExpression(data, this)
		filterStatement(data) => @writer.filterStatement(data, this)
		mode() => @writer.mode()
		popMode() => @writer.popMode()
		pushMode(mode: KSWriterMode) => @writer.pushMode(mode)
		statement(data) { // {{{
			if !this.filterStatement(data) {
				toAttributes(data, false, this)

				toStatement(this.transformStatement(data), this)
			}

			return this
		} // }}}
		transformExpression(data, writer = this) => @writer.transformExpression(data, this)
		transformStatement(data, writer = this) => @writer.transformStatement(data, this)
	}

	class KSControlWriter extends ControlWriter {
		expression(data) { // {{{
			if !this.filterExpression(data) {
				toExpression(this.transformExpression(data), this)
			}

			return this
		} // }}}
		filterExpression(data) => @writer.filterExpression(data, this)
		filterStatement(data) => @writer.filterStatement(data, this)
		mode() => @writer.mode()
		popMode() => @writer.popMode()
		pushMode(mode: KSWriterMode) => @writer.pushMode(mode)
		statement(data) { // {{{
			if !this.filterStatement(data) {
				toAttributes(data, false, this)

				toStatement(this.transformStatement(data), this)
			}

			return this
		} // }}}
		transformExpression(data, writer = this) => @writer.transformExpression(data, this)
		transformStatement(data, writer = this) => @writer.transformStatement(data, this)
		wrap(data) { // {{{
			if !this.filterExpression(data) {
				toWrap(this.transformExpression(data), this)
			}

			return this
		} // }}}
	}

	class KSExpressionWriter extends ExpressionWriter {
		expression(data) { // {{{
			if !this.filterExpression(data) {
				toExpression(this.transformExpression(data), this)
			}

			return this
		} // }}}
		filterExpression(data) => @writer.filterExpression(data, this)
		mode() => @writer.mode()
		popMode() => @writer.popMode()
		pushMode(mode: KSWriterMode) => @writer.pushMode(mode)
		transformExpression(data, writer = this) => @writer.transformExpression(data, this)
		wrap(data) { // {{{
			if !this.filterExpression(data) {
				toWrap(this.transformExpression(data), this)
			}

			return this
		} // }}}
	}

	class KSLineWriter extends LineWriter {
		expression(data) { // {{{
			if !this.filterExpression(data) {
				toExpression(this.transformExpression(data), this)
			}

			return this
		} // }}}
		filterExpression(data) => @writer.filterExpression(data, this)
		filterStatement(data) => @writer.filterStatement(data, this)
		mode() => @writer.mode()
		popMode() => @writer.popMode()
		pushMode(mode: KSWriterMode) => @writer.pushMode(mode)
		run(data, fn) { // {{{
			fn(data, this)

			return this
		} // }}}
		statement(data) { // {{{
			if !this.filterStatement(data) {
				toAttributes(data, false, this)

				toStatement(this.transformStatement(data), this)
			}

			return this
		} // }}}
		transformExpression(data, writer = this) => @writer.transformExpression(data, this)
		transformStatement(data, writer = this) => @writer.transformStatement(data, this)
		wrap(data) { // {{{
			if !this.filterExpression(data) {
				toWrap(this.transformExpression(data), this)
			}

			return this
		} // }}}
	}

	class KSObjectWriter extends ObjectWriter {
		filterExpression(data) => @writer.filterExpression(data, this)
		filterStatement(data) => @writer.filterStatement(data, this)
		mode() => @writer.mode()
		popMode() => @writer.popMode()
		pushMode(mode: KSWriterMode) => @writer.pushMode(mode)
		statement(data) { // {{{
			if !this.filterStatement(data) {
				toAttributes(data, false, this)

				toStatement(this.transformStatement(data), this)
			}

			return this
		} // }}}
		transformExpression(data, writer = this) => @writer.transformExpression(data, this)
		transformStatement(data, writer = this) => @writer.transformStatement(data, this)
	}

	func generate(data, options = null) { // {{{
		const writer = new KSWriter(options)

		toStatement(data, writer)

		return writer.toSource()
	} // }}}

	func toAttribute(data, inner, writer) { // {{{
		return writer
			.code(inner ? '#![' : '#[')
			.expression(data.declaration)
			.code(']')
	} // }}}

	func toAttributes(data, inner, writer) { // {{{
		if data.attributes?.length > 0 {
			for attribute in data.attributes {
				toAttribute(attribute, inner, writer.newLine()).done()
			}

			if inner {
				writer.newLine().done()
			}
		}
	} // }}}

	func toExpression(data, writer, header = null) {
		switch data.kind {
			NodeKind::ArrayBinding => { // {{{
				writer.code('[')

				for element, index in data.elements {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(element)
				}

				writer.code(']')
			} // }}}
			NodeKind::ArrayComprehension => { // {{{
				writer
					.code('[')
					.expression(data.body)
					.run(data.loop, toLoopHeader)
					.code(']')
			} // }}}
			NodeKind::ArrayExpression => { // {{{
				writer.code('[')

				for value, index in data.values {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(value)
				}

				writer.code(']')
			} // }}}
			NodeKind::ArrayRange => { // {{{
				writer.code('[')

				if data.from? {
					writer.expression(data.from)
				}
				else {
					writer.expression(data.then).code('<')
				}

				if data.to? {
					writer.code('..').expression(data.to)
				}
				else {
					writer.code('..<').expression(data.til)
				}

				if data.by? {
					writer.code('..').expression(data.by)
				}

				writer.code(']')
			} // }}}
			NodeKind::AttributeExpression => { // {{{
				writer.expression(data.name).code('(')

				for argument, index in data.arguments {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(argument)
				}

				writer.code(')')
			} // }}}
			NodeKind::AttributeOperation => { // {{{
				writer
					.expression(data.name)
					.code(' = ')
					.expression(data.value)
			} // }}}
			NodeKind::AwaitExpression => { // {{{
				writer.code('await ').expression(data.operation)
			} // }}}
			NodeKind::BinaryExpression => { // {{{
				if data.operator.kind == BinaryOperatorKind::TypeCasting {
					writer.code('(').expression(data.left)

					auto nf = true

					for const modifier in data.operator.modifiers {
						if modifier.kind == ModifierKind::Forced {
							writer.code(' as! ')

							nf = false
						}
						else if modifier.kind == ModifierKind::Nullable {
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

					if data.operator.kind == BinaryOperatorKind::Assignment {
						writer.code(AssignmentOperatorSymbol[data.operator.assignment])
					}
					else {
						writer.code(BinaryOperatorSymbol[data.operator.kind])
					}

					writer.wrap(data.right)
			}
			} // }}}
			NodeKind::BindingElement => { // {{{
				let computed = false
				let thisAlias = false
				let rest = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Computed {
						computed = true
					}
					else if modifier.kind == ModifierKind::Rest {
						writer.code('...')

						rest = true
					}
					else if modifier.kind == ModifierKind::ThisAlias {
						thisAlias = true
					}
				}

				if data.name? {
					if data.alias? {
						if computed {
							writer.code('[').expression(data.name).code(']')
						}
						else {
							writer.expression(data.name)
						}

						writer.code(': ')

						if thisAlias {
							writer.code('@')
						}

						writer.expression(data.alias)
					}
					else {
						if computed {
							writer.code('[')
						}

						if thisAlias {
							writer.code('@')
						}

						writer.expression(data.name)

						if computed {
							writer.code(']')
						}

						if data.type? {
							writer.code(': ').expression(data.type)
						}
					}

					if data.defaultValue? {
						writer.code(' = ').expression(data.defaultValue)
					}
				}
				else if !rest {
					writer.code('_')
				}
			} // }}}
			NodeKind::Block => { // {{{
				toAttributes(data, true, writer)

				for statement in data.statements {
					writer.statement(statement)
				}
			} // }}}
			NodeKind::CallExpression => { // {{{
				writer.expression(data.callee)

				if data.modifiers.some(modifier => modifier.kind == ModifierKind::Nullable) {
					writer.code('?')
				}

				switch data.scope.kind {
					ScopeKind::Argument => {
						writer
							.code('*$(')
							.expression(data.scope.value)

						if data.arguments.length != 0 {
							writer.code(', ')
						}
					}
					ScopeKind::Null => {
						writer.code('**(')
					}
					ScopeKind::This => {
						writer.code('(')
					}
				}

				for argument, index in data.arguments {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(argument)
				}

				writer.code(')')
			} // }}}
			NodeKind::CallMacroExpression => { // {{{
				writer
					.expression(data.callee)
					.code('!(')

				for argument, index in data.arguments {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(argument)
				}

				writer.code(')')
			} // }}}
			NodeKind::ClassDeclaration => { // {{{
				for modifier in data.modifiers {
					switch modifier.kind {
						ModifierKind::Abstract => {
							writer.code('abstract ')
						}
						ModifierKind::Sealed => {
							writer.code('sealed ')
						}
					}
				}

				writer.code('class ').expression(data.name)
			} // }}}
			NodeKind::ComparisonExpression => { // {{{
				for const value, i in data.values {
					if i % 2 == 0 {
						writer.wrap(value)
					}
					else {
						writer.code(BinaryOperatorSymbol[value.kind])
					}
				}
			} // }}}
			NodeKind::ComputedPropertyName => { // {{{
				writer
					.code('[')
					.expression(data.expression)
					.code(']')
			} // }}}
			NodeKind::ConditionalExpression => { // {{{
				writer
					.wrap(data.condition)
					.code(' ? ')
					.wrap(data.whenTrue)
					.code(' : ')
					.wrap(data.whenFalse)
			} // }}}
			NodeKind::CreateExpression => { // {{{
				writer.code('new ')

				if	data.class.kind == NodeKind::Identifier ||
					data.class.kind == NodeKind::MemberExpression ||
					data.class.kind == NodeKind::ThisExpression
				{
					writer.expression(data.class)
				}
				else {
					writer.code('(').expression(data.class).code(')')
				}

				writer.code('(')

				for argument, index in data.arguments {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(argument)
				}

				writer.code(')')
			} // }}}
			NodeKind::CurryExpression => { // {{{
				writer.expression(data.callee)

				switch data.scope.kind {
					ScopeKind::Argument => {
						writer
							.code('^$(')
							.expression(data.scope.value)

						if data.arguments.length {
							writer.code(', ')
						}
					}
					ScopeKind::Null => {
						writer.code('^^(')
					}
					ScopeKind::This => {
						writer.code('^@(')
					}
				}

				for argument, index in data.arguments {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(argument)
				}

				writer.code(')')
			} // }}}
			NodeKind::EnumExpression => { // {{{
				writer
					.expression(data.enum)
					.code('::')
					.expression(data.member)
			} // }}}
			NodeKind::ExclusionType => { // {{{
				for type, index in data.types {
					if index != 0 {
						writer.code(type.kind == NodeKind::FunctionExpression ? ' ^^ ' : ' ^ ')
					}

					writer.expression(type)
				}
			} // }}}
			NodeKind::FunctionDeclaration => { // {{{
				toFunctionHeader(data, writer => writer.code('func '), writer)
			} // }}}
			NodeKind::FunctionExpression => { // {{{
				toFunctionHeader(data, writer => {
					if writer.mode() == KSWriterMode::Property {
						if header? {
							header(writer)
						}
					}
					else {
						writer.code('func')
					}
				}, writer)

				if data.body? {
					if data.body.kind == NodeKind::Block {
						writer.newBlock().expression(data.body).done()
					}
					else {
						writer.code(' => ').expression(data.body)
					}
				}
			} // }}}
			NodeKind::FusionType => { // {{{
				for type, index in data.types {
					if index != 0 {
						writer.code(type.kind == NodeKind::FunctionExpression ? ' && ' : ' & ')
					}

					writer.expression(type)
				}
			} // }}}
			NodeKind::Identifier => { // {{{
				writer.code(data.name)
			} // }}}
			NodeKind::IfExpression => { // {{{
				writer
					.expression(data.whenTrue)
					.code(' if ')
					.expression(data.condition)

				if data.whenFalse? {
					writer
						.code(' else ')
						.expression(data.whenFalse)
				}
			} // }}}
			NodeKind::ImportArgument => { // {{{
				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Required {
						writer.code('require ')
					}
				}

				if data.name? {
					writer.expression(data.name).code(': ')
				}

				writer.expression(data.value)
			} // }}}
			NodeKind::ImportDeclarator => { // {{{
				writer.expression(data.source)

				auto autofill = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Autofill {
						autofill = true
					}
				}

				if data.arguments?.length != 0 {
					writer.code('(')

					for argument, index in data.arguments {
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

				if data.specifiers.length == 1 && data.specifiers[0].attributes.length == 0 {
					const specifier = data.specifiers[0]

					switch specifier.kind {
						NodeKind::ImportSpecifier => {
							writer.code(' for ').expression(specifier)
						}
						NodeKind::ImportExclusionSpecifier => {
							writer.code(' but ').expression(specifier)
						}
						NodeKind::ImportNamespaceSpecifier => {
							writer.code(' => ').expression(specifier)
						}
					}
				}
				else if data.specifiers.length != 0 {
					const block = writer.newBlock()

					for const specifier in data.specifiers {
						toAttributes(specifier, false, block)

						block.newLine().expression(specifier).done()
					}

					block.done()
				}
			} // }}}
			NodeKind::ImportExclusionSpecifier => { // {{{
				for const exclusion, i in data.exclusions {
					if i != 0 {
						writer.code(', ')
					}

					writer.expression(exclusion)
				}
			} // }}}
			NodeKind::ImportNamespaceSpecifier => { // {{{
				writer.expression(data.local)

				if data.specifiers?.length != 0 {
					const block = writer.newBlock()

					for specifier in data.specifiers {
						block.newLine().expression(specifier).done()
					}

					block.done()
				}
			} // }}}
			NodeKind::ImportSpecifier => { // {{{
				writer.expression(data.imported)

				if
					!(
						data.imported.kind == NodeKind::ClassDeclaration ||
						data.imported.kind == NodeKind::FunctionDeclaration ||
						data.imported.kind == NodeKind::VariableDeclarator
					)
					|| data.local.name != data.imported.name.name
				{
					writer.code(' => ').expression(data.local)
				}
			} // }}}
			NodeKind::IncludeDeclarator => { // {{{
				toAttributes(data, false, writer)

				writer.newLine().code(toQuote(data.file)).done()
			} // }}}
			NodeKind::JunctionExpression => { // {{{
				const operator = JunctionOperatorSymbol[data.operator.kind]

				for const operand, i in data.operands {
					writer.code(operator) if i != 0

					writer.expression(operand)
				}
			} // }}}
			NodeKind::LambdaExpression => { // {{{
				toFunctionHeader(data, writer => {}, writer)

				if data.body.kind == NodeKind::Block {
					writer
						.code(' =>')
						.newBlock()
						.expression(data.body)
						.done()
				}
				else {
					writer.code(' => ').expression(data.body)
				}
			} // }}}
			NodeKind::Literal => { // {{{
				writer.code(toQuote(data.value))
			} // }}}
			NodeKind::MacroExpression => { // {{{
				writer.code('macro ')

				if data.elements[0].start.line == data.elements[data.elements.length - 1].end.line {
					toMacroElements(data.elements, writer)
				}
				else {
					const o = writer.newObject()

					let line = o.newLine()

					toMacroElements(data.elements, line, o)

					o.done()
				}
			} // }}}
			NodeKind::MemberExpression => { // {{{
				let nullable = false
				let computed = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Computed {
						computed = true
					}
					else if modifier.kind == ModifierKind::Nullable {
						nullable = true
					}
				}

				writer.wrap(data.object)

				if nullable {
					writer.code('?')
				}


				if computed {
					writer.code('[').expression(data.property).code(']')
				}
				else {
					writer.code('.').expression(data.property)
				}
			} // }}}
			NodeKind::NamedArgument => { // {{{
				writer.expression(data.name).code(': ').expression(data.value)
			} // }}}
			NodeKind::NumericExpression => { // {{{
				writer.code(data.value)
			} // }}}
			NodeKind::ObjectBinding => { // {{{
				writer.code('{')

				for element, index in data.elements {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(element)
				}

				writer.code('}')
			} // }}}
			NodeKind::ObjectExpression => { // {{{
				const o = writer.newObject()

				toAttributes(data, true, o)

				o.pushMode(KSWriterMode::Property)

				for property in data.properties {
					toAttributes(property, false, o)

					o.newLine().expression(property).done()
				}

				o.popMode()

				o.done()
			} // }}}
			NodeKind::ObjectMember => { // {{{
				const value = data.value ?? data.type
				if value? {
					const element = writer.transformExpression(value)

					if element.kind == NodeKind::FunctionExpression {
						toExpression(element, writer, writer => writer.expression(data.name))
					}
					else {
						writer.expression(data.name).code(': ').expression(element)
					}
				}
				else {
					writer.expression(data.name)
				}
			} // }}}
			NodeKind::OmittedExpression => { // {{{
				if data.spread {
					writer.code('...')
				}
				else {
					writer.code('_')
				}
			} // }}}
			NodeKind::Parameter => { // {{{
				let rest: Boolean = false

				for const modifier in data.modifiers {
					switch modifier.kind {
						ModifierKind::AutoEvaluate => {
							writer.code('@')
						}
						ModifierKind::Rest => {
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
						ModifierKind::ThisAlias => {
							writer.code('@')
						}
					}
				}

				if data.name? {
					writer.expression(data.name)

					for const modifier in data.modifiers {
						switch modifier.kind {
							ModifierKind::Required => {
								writer.code('!')
							}
							ModifierKind::SetterAlias => {
								writer.code('()')
							}
						}
					}
				}
				else if !rest {
					writer.code('_')
				}

				if data.type? {
					writer.code(': ').expression(data.type)
				}

				if data.defaultValue? {
					writer.code(' = ').expression(data.defaultValue)
				}
			} // }}}
			NodeKind::PolyadicExpression => { // {{{
				writer.wrap(data.operands[0])

				for operand in data.operands from 1 {
					writer
						.code(BinaryOperatorSymbol[data.operator.kind])
						.wrap(operand)
				}
			} // }}}
			NodeKind::RegularExpression => { // {{{
				writer.code(data.value)
			} // }}}
			NodeKind::ReturnTypeReference => { // {{{
				writer.expression(data.value)
			} // }}}
			NodeKind::SequenceExpression => { // {{{
				writer.code('(')

				for expression, index in data.expressions {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(expression)
				}

				writer.code(')')
			} // }}}
			NodeKind::ShorthandProperty => { // {{{
				writer.expression(data.name)
			} // }}}
			NodeKind::SwitchConditionArray => { // {{{
				writer.code('[')

				for value, index in data.values {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(value)
				}

				writer.code(']')
			} // }}}
			NodeKind::SwitchConditionObject => { // {{{
				writer.code('{')

				for member, index in data.members {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(member)
				}

				writer.code('}')
			} // }}}
			NodeKind::SwitchConditionRange => { // {{{
				if data.from? {
					writer.expression(data.from)
				}
				else {
					writer.expression(data.then).code('<')
				}

				if data.to? {
					writer.code('..').expression(data.to)
				}
				else {
					writer.code('..<').expression(data.til)
				}

				if data.by? {
					writer.code('..').expression(data.by)
				}
			} // }}}
			NodeKind::SwitchConditionType => { // {{{
				writer
					.code('is ')
					.expression(data.type)
			} // }}}
			NodeKind::SwitchExpression => { // {{{
				writer
					.code('switch ')
					.expression(data.expression)

				const block = writer.newBlock()

				for clause in data.clauses {
					block.statement(clause)
				}

				block.done()
			} // }}}
			NodeKind::SwitchTypeCasting => { // {{{
				writer
					.expression(data.name)
					.code(' as ')
					.expression(data.type)
			} // }}}
			NodeKind::TaggedTemplateExpression => { // {{{
				writer.expression(data.tag).expression(data.template)
			} // }}}
			NodeKind::TemplateExpression => { // {{{
				writer.code('`')

				for element in data.elements {
					if element.kind == NodeKind::Literal {
						writer.code(element.value)
					}
					else {
						writer.code('\\(').expression(element).code(')')
					}
				}

				writer.code('`')
			} // }}}
			NodeKind::ThisExpression => { // {{{
				writer.code('@').expression(data.name)
			} // }}}
			NodeKind::TryExpression => { // {{{
				writer.code('try')

				if data.modifiers.some(modifier => modifier.kind == ModifierKind::Disabled) {
					writer.code('!')
				}

				writer.code(' ').expression(data.argument)

				if data.defaultValue? {
					writer.code(' ~~ ').expression(data.defaultValue)
				}
			} // }}}
			NodeKind::TypeReference => { // {{{
				if data.properties? {
					const o = writer.newObject()

					o.pushMode(KSWriterMode::Property)

					for property in data.properties {
						o.statement(property)
					}

					o.popMode()

					o.done()
				}
				else if data.elements? {
					writer.code('[')

					for const element, index in data.elements {
						if index != 0 {
							writer.code(', ')
						}

						writer.expression(element)
					}

					writer.code(']')
				}
				else {
					writer.expression(data.typeName)

					if data.typeParameters? {
						writer.code('<')

						for const parameter, index in data.typeParameters {
							if index != 0 {
								writer.code(', ')
							}

							writer.expression(parameter)
						}

						writer.code('>')
					}

					if data.modifiers.some(modifier => modifier.kind == ModifierKind::Nullable) {
						writer.code('?')
					}
				}
			} // }}}
			NodeKind::UnaryExpression => { // {{{
				if UnaryPrefixOperatorSymbol[data.operator.kind]? {
					writer
						.code(UnaryPrefixOperatorSymbol[data.operator.kind])
						.wrap(data.argument)
				}
				else {
					writer
						.wrap(data.argument)
						.code(UnaryPostfixOperatorSymbol[data.operator.kind])
				}
			} // }}}
			NodeKind::UnionType => { // {{{
				for type, index in data.types {
					if index != 0 {
						writer.code(type.kind == NodeKind::FunctionExpression ? ' || ' : ' | ')
					}

					writer.expression(type)
				}
			} // }}}
			NodeKind::UnlessExpression => { // {{{
				writer
					.expression(data.whenFalse)
					.code(' unless ')
					.expression(data.condition)
			} // }}}
			NodeKind::VariableDeclaration => { // {{{
				let immutable = false
				let autoTyping = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::AutoTyping {
						autoTyping = true
					}
					else if modifier.kind == ModifierKind::Immutable {
						immutable = true
					}
				}

				if immutable {
					writer.code('const ')
				}
				else if autoTyping {
					writer.code('auto ')
				}
				else {
					writer.code('let ')
				}

				for variable, index in data.variables {
					if index != 0 {
						writer.code(', ')
					}

					writer.expression(variable)
				}

				writer.code(' = ')

				if data.await {
					writer.code('await ')
				}

				writer.expression(data.init)
			} // }}}
			NodeKind::VariableDeclarator => { // {{{
				for const modifier in data.modifiers {
					switch modifier.kind {
						ModifierKind::Immutable => {
							writer.code('const ')
						}
						ModifierKind::Systemic => {
							writer.code('systemic ')
						}
					}
				}

				writer.expression(data.name)

				if data.type? {
					writer.code(': ').expression(data.type)
				}
			} // }}}
			=> { // {{{
				console.error(data)
				throw new Error('Not Implemented')
			} // }}}
		}
	}

	func toFunctionHeader(data, header, writer) { // {{{
		if data.modifiers? {
			for modifier in data.modifiers {
				switch modifier.kind {
					ModifierKind::Abstract => {
						writer.code('abstract ')
					}
					ModifierKind::Async => {
						writer.code('async ')
					}
					ModifierKind::Final => {
						writer.code('final ')
					}
					ModifierKind::Internal => {
						writer.code('internal ')
					}
					ModifierKind::Override => {
						writer.code('override ')
					}
					ModifierKind::Overwrite => {
						writer.code('overwrite ')
					}
					ModifierKind::Private => {
						writer.code('private ')
					}
					ModifierKind::Protected => {
						writer.code('protected ')
					}
					ModifierKind::Public => {
						writer.code('public ')
					}
					ModifierKind::Static => {
						writer.code('static ')
					}
				}
			}
		}

		header(writer)

		if data.name? {
			writer.expression(data.name)
		}

		if data.parameters? {
			writer.code('(')

			for parameter, i in data.parameters {
				if i != 0 {
					writer.code(', ')
				}

				writer.expression(parameter)
			}

			writer.code(')')
		}

		if data.type? {
			writer.code(': ').expression(data.type)
		}

		if data.throws?.length > 0 {
			writer.code(' ~ ')

			for throw, index in data.throws {
				if index != 0 {
					writer.code(', ')
				}

				writer.expression(throw)
			}
		}
	} // }}}

	func toFunctionBody(data, writer) { // {{{
		if data.kind == NodeKind::Block {
			writer
				.newBlock()
				.expression(data)
				.done()
		}
		else if data.kind == NodeKind::IfStatement {
			writer
				.code(' => ')
				.expression(data.whenTrue.value)
				.code(' if ')
				.expression(data.condition)

			if data.whenFalse? {
				writer
					.code(' else ')
					.expression(data.whenFalse.value)
			}
		}
		else if data.kind == NodeKind::ReturnStatement {
			writer.code(' => ').expression(data.value)
		}
		else {
			writer.code(' => ').expression(data)
		}
	} // }}}

	func toLoopHeader(data, writer) { // {{{
		switch data.kind {
			NodeKind::ForFromStatement => {
				let declaration = false
				let immutable = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Declarative {
						declaration = true
					}
					else if modifier.kind == ModifierKind::Immutable {
						immutable = true
					}
				}

				writer.code(' for ')

				if declaration {
					if immutable {
						writer.code('const ')
					}
					else {
						writer.code('let ')
					}
				}

				writer
					.expression(data.variable)
					.code(' from ')
					.expression(data.from)

				if data.til? {
					writer.code(' til ').expression(data.til)
				}
				else if data.to? {
					writer.code(' to ').expression(data.to)
				}

				if data.by? {
					writer.code(' by ').expression(data.by)
				}

				if data.until? {
					writer.code(' until ').expression(data.until)
				}
				else if data.while? {
					writer.code(' while ').expression(data.while)
				}

				if data.when? {
					writer.code(' when ').expression(data.when)
				}
			}
			NodeKind::ForInStatement => {
				let declaration = false
				let descending = false
				let immutable = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Declarative {
						declaration = true
					}
					else if modifier.kind == ModifierKind::Descending {
						descending = true
					}
					else if modifier.kind == ModifierKind::Immutable {
						immutable = true
					}
				}

				writer.code(' for ')

				if declaration {
					if immutable {
						writer.code('const ')
					}
					else {
						writer.code('let ')
					}
				}

				if data.value? {
					writer.expression(data.value)

					if data.index? {
						writer.code(', ').expression(data.index)
					}
				}
				else {
					writer.code(':').expression(data.index)
				}

				writer.code(' in ').expression(data.expression)

				if descending {
					writer.code(' desc')
				}

				if data.from? {
					writer.code(' from ').expression(data.from)
				}

				if data.til? {
					writer.code(' til ').expression(data.til)
				}
				else if data.to? {
					writer.code(' to ').expression(data.to)
				}

				if data.until? {
					writer.code(' until ').expression(data.until)
				}
				else if data.while? {
					writer.code(' while ').expression(data.while)
				}

				if data.when? {
					writer.code(' when ').expression(data.when)
				}
			}
			NodeKind::ForOfStatement => {
				let declaration = false
				let immutable = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Declarative {
						declaration = true
					}
					else if modifier.kind == ModifierKind::Immutable {
						immutable = true
					}
				}

				writer.code(' for ')

				if declaration {
					if immutable {
						writer.code('const ')
					}
					else {
						writer.code('let ')
					}
				}

				if data.value? {
					writer.expression(data.value)

					if data.key? {
						writer.code(', ').expression(data.key)
					}
				}
				else {
					writer.code(':').expression(data.key)
				}

				writer.code(' of ').expression(data.expression)

				if data.until? {
					writer.code(' until ').expression(data.until)
				}
				else if data.while? {
					writer.code(' while ').expression(data.while)
				}

				if data.when? {
					writer.code(' when ').expression(data.when)
				}
			}
			NodeKind::ForRangeStatement => {
				let declaration = false
				let immutable = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Declarative {
						declaration = true
					}
					else if modifier.kind == ModifierKind::Immutable {
						immutable = true
					}
				}

				writer.code(' for ')

				if declaration {
					if immutable {
						writer.code('const ')
					}
					else {
						writer.code('let ')
					}
				}

				writer
					.expression(data.value)
					.code(' in ')

				if data.from? {
					writer.expression(data.from).code('..')
				}
				else if data.then? {
					writer.expression(data.then).code('<..')
				}

				if data.til? {
					writer.code('<').expression(data.til)
				}
				else if data.to? {
					writer.code('').expression(data.to)
				}

				if data.by? {
					writer.code('..').expression(data.by)
				}

				if data.until? {
					writer.code(' until ').expression(data.until)
				}
				else if data.while? {
					writer.code(' while ').expression(data.while)
				}

				if data.when? {
					writer.code(' when ').expression(data.when)
				}
			}
		}
	} // }}}

	func toMacroElements(elements, writer, parent = null) { // {{{
		const last = elements.length - 1

		for element, index in elements {
			switch element.kind {
				MacroElementKind::Expression => {
					writer.code('#')

					if element.reification.kind == ReificationKind::Expression && element.expression.kind == NodeKind::Identifier {
						writer.expression(element.expression)
					}
					else if element.reification.kind == ReificationKind::Join {
						writer.code('j(').expression(element.expression).code(', ').expression(element.separator).code(')')
					}
					else {
						switch element.reification.kind {
							ReificationKind::Argument => {
								writer.code('a')
							}
							ReificationKind::Expression => {
								writer.code('e')
							}
							ReificationKind::Statement => {
								writer.code('s')
							}
							ReificationKind::Write => {
								writer.code('w')
							}
						}

						writer.code('(').expression(element.expression).code(')')
					}
				}
				MacroElementKind::Literal => {
					writer.code(element.value)
				}
				MacroElementKind::NewLine => {
					if index != 0 && index != last && elements[index - 1].kind != MacroElementKind::NewLine {
						parent.newLine()
					}
				}
			}
		}
	} // }}}

	func toQuote(value) { // {{{
		return '"' + value.replace(/"/g, '\\"').replace(/\n/g, '\\n') + '"'
	} // }}}

	func toStatement(data, writer) {
		switch data.kind {
			NodeKind::AccessorDeclaration => { // {{{
				const line = writer
					.newLine()
					.code('get')

				if data.body? {
					if data.body.kind == NodeKind::Block {
						line.newBlock().expression(data.body).done()
					}
					else {
						line.code(' => ').expression(data.body)
					}
				}

				line.done()
			} // }}}
			NodeKind::BreakStatement => { // {{{
				writer.newLine().code('break').done()
			} // }}}
			NodeKind::CatchClause => { // {{{
				if data.type? {
					writer
						.code('on ')
						.expression(data.type)

					if data.binding? {
						writer
							.code(' catch ')
							.expression(data.binding)
					}
				}
				else {
					writer.code('catch')

					if data.binding? {
						writer
							.code(' ')
							.expression(data.binding)
					}
				}

				writer
					.step()
					.expression(data.body)
			} // }}}
			NodeKind::ClassDeclaration => { // {{{
				const line = writer.newLine()

				for const modifier in data.modifiers {
					switch modifier.kind {
						ModifierKind::Abstract => {
							line.code('abstract ')
						}
						ModifierKind::Final => {
							line.code('final ')
						}
						ModifierKind::Sealed => {
							line.code('sealed ')
						}
						ModifierKind::Systemic => {
							line.code('systemic ')
						}
					}
				}

				line.code('class ').expression(data.name)

				if data.version? {
					line.code(`@\(data.version.major).\(data.version.minor).\(data.version.patch)`)
				}

				if data.extends? {
					line.code(' extends ').expression(data.extends)
				}

				const block = line.newBlock()

				for member in data.members {
					block.statement(member)
				}

				block.done()

				line.done()
			} // }}}
			NodeKind::ContinueStatement => { // {{{
				writer.newLine().code('continue').done()
			} // }}}
			NodeKind::DestroyStatement => { // {{{
				writer
					.newLine()
					.code('delete ')
					.expression(data.variable)
					.done()
			} // }}}
			NodeKind::DiscloseDeclaration => { // {{{
				const line = writer
					.newLine()
					.code('disclose ')
					.expression(data.name)

				const block = line.newBlock()

				for member in data.members {
					block.statement(member)
				}

				block.done()
				line.done()
			} // }}}
			NodeKind::DoUntilStatement => { // {{{
				writer
					.newControl()
					.code('do')
					.step()
					.expression(data.body)
					.step()
					.code('until ')
					.expression(data.condition)
					.done()
			} // }}}
			NodeKind::DoWhileStatement => { // {{{
				writer
					.newControl()
					.code('do')
					.step()
					.expression(data.body)
					.step()
					.code('while ')
					.expression(data.condition)
					.done()
			} // }}}
			NodeKind::EnumDeclaration => { // {{{
				const line = writer.newLine()

				for const modifier in data.modifiers {
					switch modifier.kind {
						ModifierKind::Flagged => {
							line.code('flagged ')
						}
					}
				}

				line.code('enum ').expression(data.name)

				if data.type? {
					line.code('<').expression(data.type).code('>')
				}

				const block = line.newBlock()

				for member in data.members {
					block.statement(member)
				}

				block.done()
				line.done()
			} // }}}
			NodeKind::ExportDeclaration => { // {{{
				const line = writer.newLine()

				if data.declarations.length == 1 && (!?data.declarations[0].declaration || data.declarations[0].declaration.attributes.length == 0) {
					line.code('export ').statement(data.declarations[0])
				}
				else {
					const block = line.code('export').newBlock()

					for declaration in data.declarations {
						block.statement(declaration)
					}

					block.done()
				}

				line.done()
			} // }}}
			NodeKind::ExportDeclarationSpecifier => { // {{{
				writer.statement(data.declaration)
			} // }}}
			NodeKind::ExportExclusionSpecifier => { // {{{
				const line = writer.newLine().code('*')

				if data.exclusions.length != 0 {
					line.code(' but ')

					for const exclusion, i in data.exclusions {
						if i != 0 {
							line.code(', ')
						}

						line.expression(exclusion)
					}
				}

				line.done()
			} // }}}
			NodeKind::ExportNamedSpecifier => { // {{{
				if data.local.kind == data.exported.kind && data.local.name == data.exported.name {
					writer.newLine().code(data.local.name).done()
				}
				else {
					writer.newLine().expression(data.local).code(` => \(data.exported.name)`).done()
				}
			} // }}}
			NodeKind::ExportPropertiesSpecifier => { // {{{
				const line = writer.newLine()

				line.expression(data.object)

				if data.properties.length == 1 {
					line.code(' for ').statement(data.dpropertieseclarations[0])
				}
				else {
					const block = line.code(' for').newBlock()

					for property in data.properties {
						block.statement(property)
					}

					block.done()
				}

				line.done()
			} // }}}
			NodeKind::ExportWildcardSpecifier => { // {{{
				writer.newLine().expression(data.local).code(' for *').done()
			} // }}}
			NodeKind::ExternDeclaration => { // {{{
				const line = writer.newLine()

				if data.declarations.length == 1 {
					line.code('extern ').statement(data.declarations[0])
				}
				else {
					writer.pushMode(KSWriterMode::Extern)

					const block = line.code('extern').newBlock()

					for declaration in data.declarations {
						block.statement(declaration)
					}

					block.done()

					writer.popMode()
				}

				line.done()
			} // }}}
			NodeKind::ExternOrRequireDeclaration => { // {{{
				const line = writer.newLine()

				if data.declarations.length == 1 && data.declarations[0].attributes.length == 0 {
					line.code('extern|require ').statement(data.declarations[0])
				}
				else {
					writer.pushMode(KSWriterMode::Extern)

					const block = line.code('extern|require').newBlock()

					for const declaration in data.declarations {
						block.statement(declaration)
					}

					block.done()

					writer.popMode()
				}

				line.done()
			} // }}}
			NodeKind::ExternOrImportDeclaration => { // {{{
				const line = writer.newLine()

				if data.declarations.length == 1 && data.declarations[0].attributes.length == 0 {
					line.code('extern|import ').expression(data.declarations[0])
				}
				else {
					const block = line.code('extern|import').newBlock()

					for const declaration in data.declarations {
						toAttributes(declaration, false, block)

						block.newLine().expression(declaration).done()
					}

					block.done()
				}

				line.done()
			} // }}}
			NodeKind::FallthroughStatement => { // {{{
				writer.newLine().code('fallthrough').done()
			} // }}}
			NodeKind::FieldDeclaration => { // {{{
				const line = writer.newLine()

				for modifier in data.modifiers {
					switch modifier.kind {
						ModifierKind::AutoTyping => {
							line.code('auto ')
						}
						ModifierKind::Immutable => {
							line.code('const ')
						}
						ModifierKind::Internal => {
							line.code('internal ')
						}
						ModifierKind::LateInit => {
							line.code('lateinit ')
						}
						ModifierKind::Private => {
							line.code('private ')
						}
						ModifierKind::Protected => {
							line.code('protected ')
						}
						ModifierKind::Public => {
							line.code('public ')
						}
						ModifierKind::Static => {
							line.code('static ')
						}
					}
				}

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::ThisAlias {
						line.code('@')

						break
					}
				}

				line.expression(data.name)

				if data.type? {
					line.code(': ').expression(data.type)
				}

				if data.value? {
					line.code(' = ').expression(data.value)
				}

				line.done()
			} // }}}
			NodeKind::ForFromStatement => { // {{{
				let declaration = false
				let immutable = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Declarative {
						declaration = true
					}
					else if modifier.kind == ModifierKind::Immutable {
						immutable = true
					}
				}

				const ctrl = writer
					.newControl()
					.code('for ')

				if declaration {
					if immutable {
						ctrl.code('const ')
					}
					else {
						ctrl.code('let ')
					}
				}

				ctrl
					.expression(data.variable)
					.code(' from ')
					.expression(data.from)

				if data.til? {
					ctrl.code(' til ').expression(data.til)
				}
				else {
					ctrl.code(' to ').expression(data.to)
				}

				if data.by? {
					ctrl.code(' by ').expression(data.by)
				}

				if data.until? {
					ctrl.code(' until ').expression(data.until)
				}
				else if data.while? {
					ctrl.code(' while ').expression(data.while)
				}

				if data.when? {
					ctrl.code(' when ').expression(data.when)
				}

				ctrl
					.step()
					.expression(data.body)
					.done()
			} // }}}
			NodeKind::ForInStatement => { // {{{
				let declaration = false
				let descending = false
				let immutable = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Declarative {
						declaration = true
					}
					else if modifier.kind == ModifierKind::Descending {
						descending = true
					}
					else if modifier.kind == ModifierKind::Immutable {
						immutable = true
					}
				}

				let ctrl

				if data.body.kind == NodeKind::Block {
					ctrl = writer
						.newControl()
						.code('for ')
				}
				else {
					ctrl = writer
						.newLine()
						.expression(data.body)
						.code(' for ')
				}

				if declaration {
					if immutable {
						ctrl.code('const ')
					}
					else {
						ctrl.code('let ')
					}
				}

				if data.value? {
					ctrl.expression(data.value)

					if data.type? {
						ctrl.code(': ').expression(data.type)
					}

					if data.index? {
						ctrl.code(', ').expression(data.index)
					}
				}
				else {
					ctrl.code('_, ').expression(data.index)
				}

				ctrl.code(' in ').expression(data.expression)

				if descending {
					ctrl.code(' desc')
				}

				if data.from? {
					ctrl.code(' from ').expression(data.from)
				}

				if data.til? {
					ctrl.code(' til ').expression(data.til)
				}
				else if data.to? {
					ctrl.code(' to ').expression(data.to)
				}

				if data.by? {
					ctrl.code(' by ').expression(data.by)
				}

				if data.until? {
					ctrl.code(' until ').expression(data.until)
				}
				else if data.while? {
					ctrl.code(' while ').expression(data.while)
				}

				if data.when? {
					ctrl.code(' when ').expression(data.when)
				}

				if data.body.kind == NodeKind::Block {
					ctrl
						.step()
						.expression(data.body)
				}

				ctrl.done()
			} // }}}
			NodeKind::ForRangeStatement => { // {{{
				let declaration = false
				let immutable = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Declarative {
						declaration = true
					}
					else if modifier.kind == ModifierKind::Immutable {
						immutable = true
					}
				}

				const ctrl = writer
					.newControl()
					.code('for ')

				if declaration {
					if immutable {
						ctrl.code('const ')
					}
					else {
						ctrl.code('let ')
					}
				}

				ctrl
					.expression(data.value)
					.code(' in ')

				if data.from? {
					ctrl.expression(data.from)
				}
				else {
					ctrl
						.expression(data.then)
						.code('<')
				}

				if data.to? {
					ctrl
						.code('..')
						.expression(data.to)
				}
				else {
					ctrl
						.code('..<')
						.expression(data.til)
				}

				if data.by? {
					ctrl
						.code('..')
						.expression(data.by)
				}

				if data.until? {
					ctrl.code(' until ').expression(data.until)
				}
				else if data.while? {
					ctrl.code(' while ').expression(data.while)
				}

				if data.when? {
					ctrl.code(' when ').expression(data.when)
				}

				ctrl
					.step()
					.expression(data.body)

				ctrl.done()
			} // }}}
			NodeKind::ForOfStatement => { // {{{
				let declaration = false
				let immutable = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Declarative {
						declaration = true
					}
					else if modifier.kind == ModifierKind::Immutable {
						immutable = true
					}
				}

				let ctrl

				if data.body.kind == NodeKind::Block {
					ctrl = writer
						.newControl()
						.code('for ')
				}
				else {
					ctrl = writer
						.newLine()
						.expression(data.body)
						.code(' for ')
				}

				if declaration {
					if immutable {
						ctrl.code('const ')
					}
					else {
						ctrl.code('let ')
					}
				}

				if data.value? {
					ctrl.expression(data.value)

					if data.type? {
						ctrl.code(': ').expression(data.type)
					}

					if data.key? {
						ctrl.code(', ').expression(data.key)
					}
				}
				else {
					ctrl.code('_, ').expression(data.key)
				}

				ctrl.code(' of ').expression(data.expression)

				if data.until? {
					ctrl.code(' until ').expression(data.until)
				}
				else if data.while? {
					ctrl.code(' while ').expression(data.while)
				}

				if data.when? {
					ctrl.code(' when ').expression(data.when)
				}

				if data.body.kind == NodeKind::Block {
					ctrl
						.step()
						.expression(data.body)
				}

				ctrl.done()
			} // }}}
			NodeKind::FunctionDeclaration => { // {{{
				const line = writer.newLine()

				toFunctionHeader(data, writer => {
					if writer.mode() != KSWriterMode::Extern {
						writer.code('func ')
					}
				}, line)

				if data.body? {
					toFunctionBody(data.body, line)
				}

				line.done()
			} // }}}
			NodeKind::IfStatement => { // {{{
				switch data.whenTrue.kind {
					NodeKind::Block => {
						const ctrl = writer
							.newControl()
							.code('if ')
							.expression(data.condition)
							.step()
							.expression(data.whenTrue)

						while data.whenFalse? {
							if data.whenFalse.kind == NodeKind::IfStatement {
								data = data.whenFalse

								ctrl
									.step()
									.code('else if ')
									.expression(data.condition)
									.step()
									.expression(data.whenTrue)
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
					NodeKind::ReturnStatement => {
						if data.whenTrue.value? {
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
					NodeKind::ThrowStatement => {
						writer
							.newLine()
							.code('throw ')
							.expression(data.whenTrue.value)
							.code(' if ')
							.expression(data.condition)
							.done()
					}
					=> {
						writer
							.newLine()
							.expression(data.whenTrue)
							.code(' if ')
							.expression(data.condition)
							.done()
					}
				}
			} // }}}
			NodeKind::ImplementDeclaration => { // {{{
				const line = writer
					.newLine()
					.code('impl ')
					.expression(data.variable)

				const block = line.newBlock()

				for property in data.properties {
					block.statement(property)
				}

				block.done()
				line.done()
			} // }}}
			NodeKind::ImportDeclaration => { // {{{
				const line = writer.newLine()

				if data.declarations.length == 1 && data.declarations[0].attributes.length == 0 {
					line.code('import ').expression(data.declarations[0])
				}
				else {
					const block = line.code('import').newBlock()

					for const declaration in data.declarations {
						toAttributes(declaration, false, block)

						block.newLine().expression(declaration).done()
					}

					block.done()
				}

				line.done()
			} // }}}
			NodeKind::IncludeAgainDeclaration => { // {{{
				const line = writer.newLine()

				if data.declarations.length == 1 {
					line.code('include again ').statement(data.declarations[0])
				}
				else {
					const block = line.code('include again').newBlock()

					for const declaration in data.declarations {
						block.newLine().statement(declaration).done()
					}

					block.done()
				}

				line.done()
			} // }}}
			NodeKind::IncludeDeclaration => { // {{{
				const line = writer.newLine()

				const block = line.code('include').newBlock()

				for const declaration in data.declarations {
					block.expression(declaration)
				}

				block.done()

				line.done()
			} // }}}
			NodeKind::MacroDeclaration => { // {{{
				const line = writer.newLine()

				toFunctionHeader(data, writer => {
					writer.code('macro ')
				}, line)

				if data.body.kind == NodeKind::MacroExpression {
					line.code(' => ')

					toMacroElements(data.body.elements, line)
				}
				else {
					line
						.newBlock()
						.expression(data.body)
						.done()
				}

				line.done()
			} // }}}
			NodeKind::MethodDeclaration => { // {{{
				const line = writer.newLine()

				toFunctionHeader(data, writer => {}, line)

				if data.body? {
					toFunctionBody(data.body, line)
				}

				line.done()
			} // }}}
			NodeKind::Module => { // {{{
				toAttributes(data, true, writer)

				for node in data.body {
					writer.statement(node)
				}
			} // }}}
			NodeKind::MutatorDeclaration => { // {{{
				const line = writer
					.newLine()
					.code('set')

				if data.body? {
					if data.body.kind == NodeKind::Block {
						line.newBlock().expression(data.body).done()
					}
					else {
						line.code(' => ').expression(data.body)
					}
				}

				line.done()
			} // }}}
			NodeKind::NamespaceDeclaration => { // {{{
				const line = writer.newLine()

				for modifier in data.modifiers {
					switch modifier.kind {
						ModifierKind::Sealed => {
							line.code('sealed ')
						}
					}
				}

				line.code('namespace ').expression(data.name)

				if data.statements.length != 0 {
					const block = line.newBlock()

					for statement in data.statements {
						block.statement(statement)
					}

					block.done()
				}

				line.done()
			} // }}}
			NodeKind::PropertyDeclaration => { // {{{
				const line = writer.newLine()

				for modifier in data.modifiers {
					switch modifier.kind {
						ModifierKind::Private => {
							line.code('private ')
						}
						ModifierKind::Protected => {
							line.code('protected ')
						}
						ModifierKind::Public => {
							line.code('public ')
						}
					}
				}

				line.expression(data.name)

				if data.type? {
					line.code(': ').expression(data.type)
				}

				const block = line.newBlock()

				if data.accessor? {
					block.statement(data.accessor)
				}

				if data.mutator? {
					block.statement(data.mutator)
				}

				block.done()

				if data.defaultValue? {
					line.code(' = ')

					line.expression(data.defaultValue)
				}

				line.done()
			} // }}}
			NodeKind::RequireDeclaration => { // {{{
				const line = writer.newLine()

				if data.declarations.length == 1 && data.declarations[0].attributes.length == 0 {
					line.code('require ').statement(data.declarations[0])
				}
				else {
					writer.pushMode(KSWriterMode::Extern)

					const block = line.code('require').newBlock()

					for declaration in data.declarations {
						block.statement(declaration)
					}

					block.done()

					writer.popMode()
				}

				line.done()
			} // }}}
			NodeKind::RequireOrExternDeclaration => { // {{{
				const line = writer.newLine()

				if data.declarations.length == 1 && data.declarations[0].attributes.length == 0 {
					line.code('require|extern ').statement(data.declarations[0])
				}
				else {
					writer.pushMode(KSWriterMode::Extern)

					const block = line.code('require|extern').newBlock()

					for const declaration in data.declarations {
						block.statement(declaration)
					}

					block.done()

					writer.popMode()
				}

				line.done()
			} // }}}
			NodeKind::RequireOrImportDeclaration => { // {{{
				const line = writer.newLine()

				if data.declarations.length == 1 && data.declarations[0].attributes.length == 0 {
					line.code('require|import ').expression(data.declarations[0])
				}
				else {
					const block = line.code('require|import').newBlock()

					for const declaration in data.declarations {
						toAttributes(declaration, false, block)

						block.newLine().expression(declaration).done()
					}

					block.done()
				}

				line.done()
			} // }}}
			NodeKind::ReturnStatement => { // {{{
				if data.value? {
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
			} // }}}
			NodeKind::StructDeclaration => { // {{{
				const line = writer.newLine()

				line.code('struct ').expression(data.name)

				if data.extends? {
					line.code(' extends ').expression(data.extends)
				}

				if data.fields.length != 0 {
					const block = line.newBlock()

					for const field in data.fields {
						block.statement(field)
					}

					block.done()
				}

				line.done()
			} // }}}
			NodeKind::StructField => { // {{{
				const line = writer.newLine()

				line.expression(data.name)

				if data.type? {
					line.code(': ').expression(data.type)
				}

				if data.defaultValue? {
					line.code(' = ').expression(data.defaultValue)
				}

				line.done()
			} // }}}
			NodeKind::SwitchClause => { // {{{
				const line = writer.newLine()

				if data.conditions.length != 0 {
					for condition, index in data.conditions {
						if index != 0 {
							line.code(', ')
						}

						line.expression(condition)
					}

					line.code(' ')
				}

				if data.bindings.length != 0 {
					line.code('with ')

					for binding, index in data.bindings {
						if index != 0 {
							line.code(', ')
						}

						line.expression(binding)
					}

					line.code(' ')
				}

				if data.filter? {
					line
						.code('when ')
						.expression(data.filter)
						.code(' ')
				}

				if data.body.kind == NodeKind::Block {
					line
						.code('=>')
						.newBlock()
						.expression(data.body)
						.done()
				}
				else {
					line
						.code('=> ')
						.statement(data.body)
				}

				line.done()
			} // }}}
			NodeKind::SwitchStatement => { // {{{
				const ctrl = writer
					.newControl()
					.code('switch ')
					.expression(data.expression)
					.step()

				for clause in data.clauses {
					ctrl.statement(clause)
				}

				ctrl.done()
			} // }}}
			NodeKind::ThrowStatement => { // {{{
				writer
					.newLine()
					.code('throw ')
					.expression(data.value)
					.done()
			} // }}}
			NodeKind::TryStatement => { // {{{
				const ctrl = writer
					.newControl()
					.code('try')
					.step()
					.expression(data.body)

				for clause in data.catchClauses {
					ctrl
						.step()
						.statement(clause)
				}

				if data.catchClause? {
					ctrl
						.step()
						.statement(data.catchClause)
				}

				if data.finalizer? {
					ctrl
						.step()
						.code('finally')
						.step()
						.expression(data.finalizer)
				}

				ctrl.done()
			} // }}}
			NodeKind::TupleDeclaration => { // {{{
				auto named = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::Named {
						named = true
					}
				}

				const line = writer.newLine()

				line.code('tuple ').expression(data.name)

				if data.fields.length != 0 {
					if named {
						if data.extends? {
							line.code(' extends ').expression(data.extends)
						}

						const block = line.newBlock()

						for const field in data.fields {
							block.newLine().statement(field).done()
						}

						block.done()
					}
					else {
						line.code('(')

						for const field, index in data.fields {
							if index != 0 {
								line.code(', ')
							}

							line.statement(field)
						}

						line.code(')')

						if data.extends? {
							line.code(' extends ').expression(data.extends)
						}
					}
				}
				else {
					if data.extends? {
						line.code(' extends ').expression(data.extends)
					}
				}

				line.done()
			} // }}}
			NodeKind::TupleField => { // {{{
				if data.name? {
					writer.expression(data.name)

					if data.type? {
						writer.code(': ').expression(data.type)
					}
				}
				else {
					writer.expression(data.type)
				}

				if data.defaultValue? {
					writer.code(' = ').expression(data.defaultValue)
				}
			} // }}}
			NodeKind::TypeAliasDeclaration => { // {{{
				writer
					.newLine()
					.code('type ')
					.expression(data.name)
					.code(' = ')
					.expression(data.type)
					.done()
			} // }}}
			NodeKind::UnlessStatement => { // {{{
				switch data.whenFalse.kind {
					NodeKind::Block => {
						const ctrl = writer
							.newControl()
							.code('unless ')
							.expression(data.condition)
							.step()
							.expression(data.whenFalse)

						ctrl.done()
					}
					NodeKind::ReturnStatement => {
						if data.whenFalse.value? {
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
					NodeKind::ThrowStatement => {
						writer
							.newLine()
							.code('throw ')
							.expression(data.whenFalse.value)
							.code(' unless ')
							.expression(data.condition)
							.done()
					}
					=> {
						writer
							.newLine()
							.expression(data.whenFalse)
							.code(' unless ')
							.expression(data.condition)
							.done()
					}
				}
			} // }}}
			NodeKind::UntilStatement => { // {{{
				writer
					.newControl()
					.code('until ')
					.expression(data.condition)
					.step()
					.expression(data.body)
					.done()
			} // }}}
			NodeKind::VariableDeclaration => { // {{{
				let autoTyping = false
				let immutable = false
				let lateInit = false

				for const modifier in data.modifiers {
					if modifier.kind == ModifierKind::AutoTyping {
						autoTyping = true
					}
					else if modifier.kind == ModifierKind::Immutable {
						immutable = true
					}
					else if modifier.kind == ModifierKind::LateInit {
						lateInit = true
					}
				}

				const line = writer.newLine()

				if lateInit {
					line.code('lateinit ')
				}

				if immutable {
					line.code('const ')
				}
				else if autoTyping {
					line.code('auto ')
				}
				else {
					line.code('let ')
				}

				for variable, index in data.variables {
					if index != 0 {
						line.code(', ')
					}

					line.expression(variable)
				}

				if data.init? {
					line.code(' = ')

					if data.await {
						line.code('await ')
					}

					line.expression(data.init)
				}

				line.done()
			} // }}}
			NodeKind::WhileStatement => { // {{{
				writer
					.newControl()
					.code('while ')
					.expression(data.condition)
					.step()
					.expression(data.body)
					.done()
			} // }}}
			=> { // {{{
				writer
					.newLine()
					.expression(data)
					.done()
			} // }}}
		}
	}

	func toWrap(data, writer) {
		switch data.kind {
			NodeKind::BinaryExpression when data.operator.kind != BinaryOperatorKind::TypeCasting => { // {{{
				writer
					.code('(')
					.expression(data)
					.code(')')
			} // }}}
			NodeKind::ComparisonExpression, NodeKind::ConditionalExpression, NodeKind::PolyadicExpression => { // {{{
				writer
					.code('(')
					.expression(data)
					.code(')')
			} // }}}
			=> { // {{{
				writer.expression(data)
			} // }}}
		}
	}

	export generate, KSWriter, KSWriterMode
}

export Generator.generate