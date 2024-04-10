// Copyright (C) 2013-2020 Blockstack PBC, a public benefit corporation
// Copyright (C) 2020 Stacks Open Internet Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

use hashbrown::hash_map::{
    HashMap, {Entry, OccupiedEntry, VacantEntry},
};
use hashbrown::HashSet;
use std::mem;

use std::hash::BuildHasher;

use crate::vm::analysis::AnalysisDatabase;
use crate::vm::ast::errors::{ParseError, ParseErrors, ParseResult};
use crate::vm::ast::types::{BuildASTPass, ContractAST, PreExpressionsDrain};
use crate::vm::functions::define::{DefineFunctions, DefineFunctionsParsed};
use crate::vm::functions::NativeFunctions;
use crate::vm::representations::PreSymbolicExpressionType::{
    Atom, AtomValue, FieldIdentifier, List, SugaredFieldIdentifier, TraitReference, Tuple,
};
// use std::collections::{HashMap, hash_map::{Entry, OccupiedEntry, VacantEntry}};
use crate::vm::representations::{
    ClarityName, PreSymbolicExpression, SymbolicExpression, TraitDefinition,
};
use crate::vm::types::{QualifiedContractIdentifier, TraitIdentifier, Value};
use crate::vm::ClarityVersion;

pub struct TraitsResolver {}

impl BuildASTPass for TraitsResolver {
    fn run_pass(contract_ast: &mut ContractAST, _version: ClarityVersion) -> ParseResult<()> {
        let mut command = TraitsResolver::new();
        command.run(contract_ast)?;
        Ok(())
    }
}

pub trait EntryExt<'a, K: 'a, V: 'a, S: 'a>
where
    S: BuildHasher,
    Self: Sized,
{
    fn map_occupied(
        &mut self,
        f: impl FnOnce(&mut OccupiedEntry<'a, K, V, S>) -> Result<(), ParseErrors>,
    ) -> Result<&mut Self, ParseErrors>;

    fn map_vacant(
        &mut self,
        f: impl FnOnce(&mut VacantEntry<'a, K, V, S>) -> Result<(), ParseErrors>,
    ) -> Result<&mut Self, ParseErrors>;
}

impl<'a, K: 'a, V: 'a, S: 'a> EntryExt<'a, K, V, S> for Entry<'a, K, V, S>
where
    S: BuildHasher,
{
    fn map_occupied(
        &mut self,
        f: impl FnOnce(&mut OccupiedEntry<'a, K, V, S>) -> Result<(), ParseErrors>,
    ) -> Result<&mut Self, ParseErrors> {
        if let Entry::Occupied(ref mut e) = self {
            f(e)?;
        }
        Ok(self)
    }

    fn map_vacant(
        &mut self,
        f: impl FnOnce(&mut VacantEntry<'a, K, V, S>) -> Result<(), ParseErrors>,
    ) -> Result<&mut Self, ParseErrors> {
        if let Entry::Vacant(ref mut e) = self {
            f(e)?;
        }
        Ok(self)
    }
}

fn print_type_of<T>(_: &T) {
    println!("{:?}", std::any::type_name::<T>())
}

impl TraitsResolver {
    fn new() -> TraitsResolver {
        TraitsResolver {}
    }

    pub fn run(&mut self, contract_ast: &mut ContractAST) -> ParseResult<()> {
        let mut referenced_traits = HashMap::new();

        for exp in contract_ast.pre_expressions.iter() {
            // Top-level comment nodes have been filtered from `args` by `try_parse_pre_expr`.
            let Some((define_type, args)) = self.try_parse_pre_expr(&exp) else {
                continue;
            };

            match define_type {
                DefineFunctions::Trait => {
                    if args.len() != 2 {
                        return Err(ParseErrors::DefineTraitBadSignature.into());
                    }

                    match (&args[0].pre_expr, &args[1].pre_expr) {
                        (Atom(trait_name), List(trait_definition)) => {
                            // Check for collisions
                            // match contract_ast.referenced_traits.entry(trait_name.to_owned()) {
                            //     Entry::Occupied(e) => {
                            //         return Err(ParseErrors::NameAlreadyUsed(
                            //             trait_name.to_string(),
                            //         )
                            //         .into());
                            //     }
                            //     Entry::Vacant(e) => {
                            //         // Traverse and probe for generics nested in the trait definition
                            //         self.probe_for_generics(
                            //             trait_definition.iter(),
                            //             &mut referenced_traits,
                            //             true,
                            //         )?;
                            //         let trait_id = TraitIdentifier {
                            //             name: trait_name.clone(),
                            //             contract_identifier: contract_ast
                            //                 .contract_identifier
                            //                 .clone(),
                            //         };
                            //         e.insert(TraitDefinition::Defined(trait_id));
                            //     }
                            // }
                            contract_ast
                                .referenced_traits
                                .entry(trait_name.to_owned())
                                .map_occupied(|_| {
                                    return Err(ParseErrors::NameAlreadyUsed(
                                        trait_name.to_string(),
                                    )
                                    .into());
                                })?
                                .map_vacant(|e| {
                                    print_type_of(&e);
                                    self.probe_for_generics(
                                        trait_definition.iter(),
                                        &mut referenced_traits,
                                        true,
                                    );
                                    let trait_id = TraitIdentifier {
                                        name: trait_name.clone(),
                                        contract_identifier: contract_ast
                                            .contract_identifier
                                            .clone(),
                                    };
                                    e.insert(TraitDefinition::Defined(trait_id));
                                    Ok(())
                                });
                            //e type before in vacant call: VacantEntry<'static, ClarityName, TraitDefinition, BuildHasherDefault<AHasher>, Global>
                            //e type with trait impl in vacant call: hashbrown::hash_map::VacantEntry<'_, ClarityName, TraitDefinition>
                        }
                        _ => return Err(ParseErrors::DefineTraitBadSignature.into()),
                    }
                }
                DefineFunctions::UseTrait => {
                    if args.len() != 2 {
                        return Err(ParseErrors::ImportTraitBadSignature.into());
                    }

                    if let Some(trait_name) = args[0].match_atom() {
                        // Check for collisions
                        match contract_ast.referenced_traits.entry(trait_name.to_owned()) {
                            Entry::Occupied(_) => {
                                return Err(
                                    ParseErrors::NameAlreadyUsed(trait_name.to_string()).into()
                                );
                            }
                            Entry::Vacant(e) => {
                                let trait_id = match &args[1].pre_expr {
                                    SugaredFieldIdentifier(contract_name, name) => {
                                        let contract_identifier = QualifiedContractIdentifier::new(
                                            contract_ast.contract_identifier.issuer.clone(),
                                            contract_name.clone(),
                                        );
                                        TraitIdentifier {
                                            name: name.clone(),
                                            contract_identifier,
                                        }
                                    }
                                    FieldIdentifier(trait_identifier) => trait_identifier.clone(),
                                    _ => return Err(ParseErrors::ImportTraitBadSignature.into()),
                                };
                                e.insert(TraitDefinition::Imported(trait_id));
                            }
                        }
                    } else {
                        return Err(ParseErrors::ImportTraitBadSignature.into());
                    }
                }
                DefineFunctions::ImplTrait => {
                    if args.len() != 1 {
                        return Err(ParseErrors::ImplTraitBadSignature.into());
                    }

                    let trait_id = match &args[0].pre_expr {
                        SugaredFieldIdentifier(contract_name, name) => {
                            let contract_identifier = QualifiedContractIdentifier::new(
                                contract_ast.contract_identifier.issuer.clone(),
                                contract_name.clone(),
                            );
                            TraitIdentifier {
                                name: name.clone(),
                                contract_identifier,
                            }
                        }
                        FieldIdentifier(trait_identifier) => trait_identifier.clone(),
                        _ => return Err(ParseErrors::ImplTraitBadSignature.into()),
                    };
                    contract_ast.implemented_traits.insert(trait_id);
                }
                DefineFunctions::PublicFunction
                | DefineFunctions::PrivateFunction
                | DefineFunctions::ReadOnlyFunction => {
                    // Traverse and probe for generics in functions type definitions
                    self.probe_for_generics(args.into_iter(), &mut referenced_traits, true)?;
                }
                DefineFunctions::Constant
                | DefineFunctions::Map
                | DefineFunctions::PersistedVariable
                | DefineFunctions::FungibleToken
                | DefineFunctions::NonFungibleToken => {
                    if !args.is_empty() {
                        self.probe_for_generics(
                            args[1..].to_vec().into_iter(),
                            &mut referenced_traits,
                            false,
                        )?;
                    }
                }
            };
        }

        for (trait_reference, expr) in referenced_traits {
            if !contract_ast
                .referenced_traits
                .contains_key(&trait_reference)
            {
                let mut err = ParseError::new(ParseErrors::TraitReferenceUnknown(
                    trait_reference.to_string(),
                ));
                err.set_pre_expression(&expr);
                return Err(err);
            }
        }

        Ok(())
    }

    fn try_parse_pre_expr<'a>(
        &self,
        expression: &'a PreSymbolicExpression,
    ) -> Option<(DefineFunctions, Vec<&'a PreSymbolicExpression>)> {
        let expressions = expression.match_list()?;
        // Filter comment nodes out of the list of expressions.
        let mut filtered_expressions = expressions
            .iter()
            .filter(|expr| expr.match_comment().is_none());
        let function_name = filtered_expressions.next()?.match_atom()?;
        let define_type = DefineFunctions::lookup_by_name(function_name)?;
        Some((define_type, filtered_expressions.collect()))
    }

    #[allow(clippy::only_used_in_recursion)]
    fn probe_for_generics<'a>(
        &mut self,
        exprs: impl Iterator<Item = &'a PreSymbolicExpression>,
        referenced_traits: &mut HashMap<ClarityName, PreSymbolicExpression>,
        should_reference: bool,
    ) -> ParseResult<()> {
        for expression in exprs {
            match &expression.pre_expr {
                List(list) => {
                    self.probe_for_generics(list.iter(), referenced_traits, should_reference)?;
                }
                TraitReference(trait_name) => {
                    if should_reference {
                        referenced_traits.insert(trait_name.clone(), expression.clone());
                    } else {
                        return Err(ParseErrors::TraitReferenceNotAllowed.into());
                    }
                }
                Tuple(atoms) => {
                    self.probe_for_generics(atoms.iter(), referenced_traits, should_reference)?;
                }
                _ => { /* no-op */ }
            }
        }
        Ok(())
    }
}
