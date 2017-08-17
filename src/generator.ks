/**
 * generator.ks
 * Version 0.1.0
 * August 14th, 2017
 *
 * Copyright (c) 2017 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
#![runtime(type(alias='KSType'))]

include once {
	'@kaoscript/ast'
	'@kaoscript/source-writer'
}

extern console

export namespace AST {
	const AssignmentOperatorSymbol = {
		`\(AssignmentOperatorKind::Addition)`			: '+='
		`\(AssignmentOperatorKind::BitwiseAnd)`			: '&='
		`\(AssignmentOperatorKind::BitwiseLeftShift)`	: '<<='
		`\(AssignmentOperatorKind::BitwiseOr)`			: '|='
		`\(AssignmentOperatorKind::BitwiseRightShift)`	: '>>='
		`\(AssignmentOperatorKind::BitwiseXor)`			: '^='
		`\(AssignmentOperatorKind::Equality)`			: '='
		`\(AssignmentOperatorKind::Existential)`		: '?='
		`\(AssignmentOperatorKind::Modulo)`				: '%='
		`\(AssignmentOperatorKind::Multiplication)`		: '*='
		`\(AssignmentOperatorKind::NonExistential)`		: '!?='
		`\(AssignmentOperatorKind::NullCoalescing)`		: '??='
		`\(AssignmentOperatorKind::Subtraction)`		: '-='
	}
	
	const BinaryOperatorSymbol = {
		`\(BinaryOperatorKind::Addition)`			: '+'
		`\(BinaryOperatorKind::And)`				: '&&'
		`\(BinaryOperatorKind::BitwiseAnd)`			: '&'
		`\(BinaryOperatorKind::BitwiseLeftShift)`	: '<<'
		`\(BinaryOperatorKind::BitwiseOr)`			: '|'
		`\(BinaryOperatorKind::BitwiseRightShift)`	: '>>'
		`\(BinaryOperatorKind::BitwiseXor)`			: '^'
		`\(BinaryOperatorKind::Division)`			: '/'
		`\(BinaryOperatorKind::Equality)`			: '=='
		`\(BinaryOperatorKind::GreaterThan)`		: '>'
		`\(BinaryOperatorKind::GreaterThanOrEqual)`	: '>='
		`\(BinaryOperatorKind::Inequality)`			: '!='
		`\(BinaryOperatorKind::LessThan)`			: '<'
		`\(BinaryOperatorKind::LessThanOrEqual)`	: '<='
		`\(BinaryOperatorKind::Modulo)`				: '%'
		`\(BinaryOperatorKind::Multiplication)`		: '*'
		`\(BinaryOperatorKind::NullCoalescing)`		: '??'
		`\(BinaryOperatorKind::Or)`					: '||'
		`\(BinaryOperatorKind::Subtraction)`		: '-'
		`\(BinaryOperatorKind::TypeCasting)`		: 'as'
		`\(BinaryOperatorKind::TypeEquality)`		: 'is'
		`\(BinaryOperatorKind::TypeInequality)`		: 'is not'
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
		`\(UnaryOperatorKind::IncrementPostfix)`	: '++'
	}
	
	export func generate(data) { // {{{
		const writer = new Writer({
			terminators: {
				line: ''
				list: ''
			}
		})
		
		toSource(data, writer)
		
		let source = ''
		
		for fragment in writer.toArray() {
			source += fragment.code
		}
		
		if source.length {
			return source.substr(0, source.length - 1)
		}
		else {
			return source
		}
	} // }}}
	
	func toAttribute(data, global, writer) { // {{{
		writer.code(global ? '#![' : '#[')
		
		toSource(data.declaration, writer)
		
		writer.code(']')
		
		return writer
	} // }}}
	
	func toAttributes(data, global, writer) { // {{{
		if data.attributes? {
			for attribute in data.attributes {
				toAttribute(attribute, global, writer.newLine()).done()
			}
		}
	} // }}}
	
	func toFunctionHeader(data, header, writer) { // {{{
		for modifier in data.modifiers {
			switch modifier.kind {
				ModifierKind::Abstract => {
					writer.code('abstract ')
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
		
		header(writer)
		
		if data.name? {
			toSource(data.name, writer)
		}
		
		writer.code('(')
		
		for parameter, i in data.parameters {
			if i != 0 {
				writer.code(', ')
			}
			
			toSource(parameter, writer)
		}
		
		writer.code(')')
		
		for modifier in data.modifiers {
			switch modifier.kind {
				ModifierKind::Async => {
					writer.code(' async')
				}
			}
		}
		
		if data.type? {
			toSource(data.type, writer.code(': '))
		}
		
		if data.throws?.length > 0 {
			writer.code(' ~ ')
			
			for throw, index in data.throws {
				if index != 0 {
					writer.code(', ')
				}
				
				toSource(throw, writer)
			}
		}
	} // }}}
	
	func toLoopHeader(data, writer) { // {{{
		switch data.kind {
			NodeKind::ForInStatement => {
				writer.code(' for ')
				
				if data.value? {
					toSource(data.value, writer)
					
					if data.index? {
						toSource(data.index, writer.code(', '))
					}
				}
				else {
					toSource(data.index, writer.code(':'))
				}
				
				toSource(data.expression, writer.code(' in '))
				
				if data.when? {
					toSource(data.when, writer.code(' when '))
				}
			}
			=> {
				console.error(data)
				throw new Error('Not Implemented')
			}
		}
	} // }}}
	
	func toQuote(value) { // {{{
		return '"' + value.replace(/"/g, '\\"').replace(/\n/g, '\\n') + '"'
	} // }}}
	
	export func toSource(data, writer) {
		//console.log(data)
		switch data.kind {
			NodeKind::AccessorDeclaration => { // {{{
				writer.code('get')
				
				if data.body? {
					if data.body.kind == NodeKind::Block {
						toSource(data.body, writer)
					}
					else {
						toSource(data.body, writer.code(' => '))
					}
				}
			} // }}}
			NodeKind::ArrayBinding => { // {{{
				writer.code('[')
				
				for element, index in data.elements {
					if index != 0 {
						writer.code(', ')
					}
					
					toSource(element, writer)
				}
				
				writer.code(']')
			} // }}}
			NodeKind::ArrayComprehension => { // {{{
				writer.code('[')
				
				toSource(data.body, writer)
				
				toLoopHeader(data.loop, writer)
				
				writer.code(']')
			} // }}}
			NodeKind::ArrayExpression => { // {{{
				writer.code('[')
				
				for value, index in data.values {
					if index != 0 {
						writer.code(', ')
					}
					
					toSource(value, writer)
				}
				
				writer.code(']')
			} // }}}
			NodeKind::ArrayRange => { // {{{
				writer.code('[')
				
				if data.from? {
					toSource(data.from, writer)
				}
				else {
					toSource(data.then, writer).code('<')
				}
				
				if data.to? {
					toSource(data.to, writer.code('..'))
				}
				else {
					toSource(data.til, writer.code('..<'))
				}
				
				if data.by? {
					toSource(data.by, writer.code('..'))
				}
				
				writer.code(']')
			} // }}}
			NodeKind::AttributeExpression => { // {{{
				toSource(data.name, writer).code('(')
				
				for argument, index in data.arguments {
					if index != 0 {
						writer.code(', ')
					}
					
					toSource(argument, writer)
				}
				
				writer.code(')')
			} // }}}
			NodeKind::AttributeOperation => { // {{{
				toSource(data.name, writer)
				
				writer.code(' = ')
				
				toSource(data.value, writer)
			} // }}}
			NodeKind::AwaitExpression => { // {{{
				toSource(data.operation, writer.code('await '))
			} // }}}
			NodeKind::BinaryExpression => { // {{{
				toSource(data.left, writer)
				
				if data.operator.kind == BinaryOperatorKind::Assignment {
					writer.code(` \(AssignmentOperatorSymbol[data.operator.assignment]) `)
				}
				else {
					writer.code(` \(BinaryOperatorSymbol[data.operator.kind]) `)
				}
				
				toSource(data.right, writer)
			} // }}}
			NodeKind::BindingElement => { // {{{
				if data.spread {
					writer.code('...')
				}
				else if data.alias? {
					if data.alias.computed {
						toSource(data.alias, writer.code('[')).code(']: ')
					}
					else {
						toSource(data.alias, writer).code(': ')
					}
				}
				
				toSource(data.name, writer)
				
				if data.defaultValue? {
					toSource(data.defaultValue, writer.code(' = '))
				}
			} // }}}
			NodeKind::Block => { // {{{
				const block = writer.newBlock()
				
				for statement in data.statements {
					toAttributes(statement, false, writer)
					
					toSource(statement, block.newLine()).done()
				}
				
				block.done()
			} // }}}
			NodeKind::CallExpression => { // {{{
				toSource(data.callee, writer).code('(')
				
				for argument, index in data.arguments {
					if index != 0 {
						writer.code(', ')
					}
					
					toSource(argument, writer)
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
				
				toSource(data.name, writer.code('class '))
				
				if data.version? {
					writer.code(`@\(data.version.major).\(data.version.minor).\(data.version.patch)`)
				}
				
				if data.extends? {
					toSource(data.extends, writer.code(' extends '))
				}
				
				const block = writer.newBlock()
				
				for member in data.members {
					toAttributes(member, false, writer)
					
					toSource(member, block.newLine()).done()
				}
				
				block.done()
			} // }}}
			NodeKind::ConditionalExpression => { // {{{
				toSource(data.condition, writer)
				
				toSource(data.whenTrue, writer.code(' ? '))
				
				toSource(data.whenFalse, writer.code(' : '))
			} // }}}
			NodeKind::CreateExpression => { // {{{
				writer.code('new ')
				
				toSource(data.class, writer)
				
				writer.code('(')
				
				for argument, index in data.arguments {
					if index != 0 {
						writer.code(', ')
					}
					
					toSource(argument, writer)
				}
				
				writer.code(')')
			} // }}}
			NodeKind::DoUntilStatement => {
				const ctrl = writer.newControl(writer._indent)
				
				ctrl.code('do').step()
				
				toSource(data.body, ctrl)
				
				toSource(data.condition, ctrl.step().code('until '))
				
				ctrl.done()
			}
			NodeKind::ExportDeclaration => { // {{{
				writer.code('export ')
				
				if data.declarations.length == 1 {
					toSource(data.declarations[0], writer)
				}
				else {
					const block = writer.newBlock()
					
					for declaration in data.declarations {
						toSource(declaration, block.newLine()).done()
					}
					
					block.done()
				}
			} // }}}
			NodeKind::ExternDeclaration => { // {{{
				writer.code('extern ')
				
				if data.declarations.length == 1 {
					toSource(data.declarations[0], writer)
				}
				else {
					const block = writer.newBlock()
					
					for declaration in data.declarations {
						toSource(declaration, block.newLine()).done()
					}
					
					block.done()
				}
			} // }}}
			NodeKind::FieldDeclaration => { // {{{
				for modifier in data.modifiers {
					switch modifier.kind {
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
				
				toSource(data.name, writer)
				
				if data.type? {
					toSource(data.type, writer.code(': '))
				}
				
				if data.defaultValue? {
					toSource(data.defaultValue, writer.code(' = '))
				}
			} // }}}
			NodeKind::FunctionDeclaration => { // {{{
				toFunctionHeader(data, writer => {
					writer.code('func ')
				}, writer)
				
				if data.body.kind == NodeKind::Block {
					toSource(data.body, writer)
				}
				else {
					toSource(data.body, writer.code(' => '))
				}
			} // }}}
			NodeKind::FunctionExpression => { // {{{
				toFunctionHeader(data, writer => {}, writer)
				
				if data.body.kind == NodeKind::Block {
					toSource(data.body, writer)
				}
				else {
					toSource(data.body, writer.code(' => '))
				}
			} // }}}
			NodeKind::Identifier => { // {{{
				writer.code(data.name)
			} // }}}
			NodeKind::IfStatement => { // {{{
				toSource(data.condition, writer.code('if '))
				
				toSource(data.whenTrue, writer)
				
				if data.whenFalse? {
					toSource(data.whenFalse, writer.code('else '))
				}
			} // }}}
			NodeKind::ImportDeclaration => { // {{{
				writer.code('import ')
				
				if data.declarations.length == 1 {
					toSource(data.declarations[0], writer)
				}
				else {
					const block = writer.newBlock()
					
					for declaration in data.declarations {
						toSource(declaration, block.newLine()).done()
					}
					
					block.done()
				}
			} // }}}
			NodeKind::ImportDeclarator => { // {{{
				toSource(data.source, writer)
				
				if data.specifiers.length == 1 {
					const specifier = data.specifiers[0]
					
					switch specifier.kind {
						NodeKind::ImportSpecifier => {
							if specifier.imported.name == specifier.local.name {
								toSource(specifier.local, writer.code(' for '))
							}
							else {
							}
						}
					}
				}
				else {
					const block = writer.newBlock()
					
					for specifier in data.specifiers {
						toSource(specifier, block.newLine()).done()
					}
					
					block.done()
				}
			} // }}}
			NodeKind::Literal => { // {{{
				writer.code(toQuote(data.value))
			} // }}}
			NodeKind::MemberExpression => { // {{{
				toSource(data.object, writer)
				
				if data.computed {
					toSource(data.property, writer.code('[')).code(']')
				}
				else {
					toSource(data.property, writer.code('.'))
				}
			} // }}}
			NodeKind::MethodDeclaration => { // {{{
				toFunctionHeader(data, writer => {}, writer)
				
				if data.body? {
					if data.body.kind == NodeKind::Block {
						toSource(data.body, writer)
					}
					else {
						toSource(data.body, writer.code(' => '))
					}
				}
			} // }}}
			NodeKind::Module => { // {{{
				toAttributes(data, true, writer)
				
				for node in data.body {
					toAttributes(node, false, writer)
					
					toSource(node, writer.newLine()).done()
				}
			} // }}}
			NodeKind::MutatorDeclaration => { // {{{
				writer.code('set')
				
				if data.body? {
					if data.body.kind == NodeKind::Block {
						toSource(data.body, writer)
					}
					else {
						toSource(data.body, writer.code(' => '))
					}
				}
			} // }}}
			NodeKind::NamespaceDeclaration => { // {{{
				toSource(data.name, writer.code('namespace '))
				
				const block = writer.newBlock()
				
				for statement in data.statements {
					toAttributes(statement, false, writer)
					
					toSource(statement, block.newLine()).done()
				}
				
				block.done()
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
					
					toSource(element, writer)
				}
				
				writer.code('}')
			} // }}}
			NodeKind::ObjectExpression => { // {{{
				const o = writer.newObject()
				
				for property in data.properties {
					toAttributes(property, false, o)
					
					toSource(property, o.newLine()).done()
				}
				
				o.done()
			} // }}}
			NodeKind::ObjectMember => { // {{{
				toSource(data.name, writer)
				
				if data.value.kind != NodeKind::FunctionExpression {
					writer.code(': ')
				}
				
				toSource(data.value, writer)
			} // }}}
			NodeKind::OmittedExpression => { // {{{
				if data.spread {
					writer.code('...')
				}
			} // }}}
			NodeKind::Parameter => { // {{{
				for modifier in data.modifiers {
					switch modifier.kind {
						ModifierKind::Rest => {
							writer.code('...')
							
							if modifier.arity.min != 0 || modifier.arity.max != Infinity {
								writer.code('{')
								
								if modifier.arity.min != 0 {
									writer.code(modifier.arity.min)
								}
								
								writer.code(',')
								
								if modifier.arity.max != Infinity {
									writer.code(modifier.arity.max)
								}
								
								writer.code('}')
							}
						}
						ModifierKind::ThisAlias => {
							writer.code('@')
						}
					}
				}
				
				if data.name? {
					toSource(data.name, writer)
					
					for modifier in data.modifiers {
						switch modifier.kind {
							ModifierKind::SetterAlias => {
								writer.code('()')
							}
						}
					}
				}
				
				if data.type? {
					toSource(data.type, writer.code(': '))
				}
				
				if data.defaultValue? {
					toSource(data.defaultValue, writer.code(' = '))
				}
			} // }}}
			NodeKind::PolyadicExpression => { // {{{
				toSource(data.operands[0], writer)
				
				for operand in data.operands from 1 {
					writer.code(` \(BinaryOperatorSymbol[data.operator.kind]) `)
					
					toSource(operand, writer)
				}
			} // }}}
			NodeKind::PropertyDeclaration => { // {{{
				for modifier in data.modifiers {
					switch modifier.kind {
						ModifierKind::Private => {
							writer.code('private ')
						}
						ModifierKind::Protected => {
							writer.code('protected ')
						}
						ModifierKind::Public => {
							writer.code('public ')
						}
					}
				}
				
				toSource(data.name, writer)
				
				if data.type? {
					toSource(data.type, writer.code(': '))
				}
				
				const block = writer.newBlock()
				
				if data.accessor? {
					toSource(data.accessor, block.newLine()).done()
				}
				
				if data.mutator? {
					toSource(data.mutator, block.newLine()).done()
				}
				
				block.done()
			} // }}}
			NodeKind::ReturnStatement => { // {{{
				if data.value? {
					toSource(data.value, writer.code('return '))
				}
				else {
					writer.code('return')
				}
			} // }}}
			NodeKind::TemplateExpression => { // {{{
				writer.code('`')
				
				for element in data.elements {
					if element.kind == NodeKind::Literal {
						writer.code(element.value)
					}
					else {
						toSource(element, writer.code('\\(')).code(')')
					}
				}
				
				writer.code('`')
			} // }}}
			NodeKind::ThisExpression => { // {{{
				toSource(data.name, writer.code('@'))
			} // }}}
			NodeKind::ThrowStatement => { // {{{
				toSource(data.value, writer.code('throw '))
			} // }}}
			NodeKind::TypeReference => { // {{{
				toSource(data.typeName, writer)
				
				if data.nullable {
					writer.code('?')
				}
			} // }}}
			NodeKind::UnaryExpression => { // {{{
				if UnaryPrefixOperatorSymbol[data.operator.kind]? {
					writer.code(UnaryPrefixOperatorSymbol[data.operator.kind])
					
					toSource(data.argument, writer)
				}
				else {
					toSource(data.argument, writer)
					
					writer.code(UnaryPostfixOperatorSymbol[data.operator.kind])
				}
			} // }}}
			NodeKind::VariableDeclaration => { // {{{
				writer.code(data.rebindable ? 'let ' : 'const ')
				
				for variable, index in data.variables {
					if index != 0 {
						writer.code(', ')
					}
					
					toSource(variable, writer)
				}
				
				if data.init? {
					writer.code(data.autotype ? ' := ' : ' = ')
					
					if data.await {
						writer.code('await ')
					}
					
					toSource(data.init, writer)
				}
			} // }}}
			NodeKind::VariableDeclarator => { // {{{
				toSource(data.name, writer)
				
				if data.type? {
					toSource(data.type, writer.code(': '))
				}
			} // }}}
			=> { // {{{
				console.error(data)
				throw new Error('Not Implemented')
			} // }}}
		}
		
		return writer
	}
}

export const generate = AST.generate