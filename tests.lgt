:- object(tests,
	extends(lgtunit)).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'Unit tests for Frames'
	]).

	cover(frames).
	cover(slimowl_inheritance).

	:- dynamic(test_collection/1).
	:- private(test_collection/1).
	:- initialization((
		json::parse(file('test_db.json'), JSON),
		navltree::as_nested_dictionary(JSON, Dict),
		asserta(test_collection(Dict))
	)).

	setup :-
		create_object(
			inheritance_calculator,
			[imports(slimowl_inheritance)],
			[],
			[]),
		frames::set_facet(calculate, inheritance_calculator).

	% Setting facets
	test(not_suitable, error(domain_error(protocol_relation, frames))) :-
		frames::set_facet(calculate, frames).

	% READING
	test(plain_slots, true(Family-Spacing == 'Lily'-16)) :-
		test_collection(Frames),
		frames::get_frame(Frames, 'Onion', [family-Family, spacing-Spacing]).
	test(list_slots, true(Types == ['NamedIndividual', 'Herb'])):-
		test_collection(Frames),
		findall(Type, frames::get_frame(Frames, 'Mint', [type-Type]), Types).
	test(inherited_value, true(Edible == 'leaves'), [note('Mint is a herb, herbs have edible leaves')]) :-
		test_collection(Frames),
		frames::get_frame(Frames, 'Mint', [edible-Edible]).


	test(no_such_slot, fail) :-
		test_collection(Frames),
		frames::get_frame(Frames, 'Carrot', [email-_Email]).
	test(no_such_frame, fail) :-
		test_collection(Frames),
		frames::get_frame(Frames, 'Ivy', [_Key-_Value]).
	test(var_collection, error(instantiation_error)) :-
		frames::get_frame(_Var, subject, [key-value]).
	test(var_pairs, error(instantiation_error)) :-
		test_collection(Frames),
		frames::get_frame(Frames, subject, _Var).

	test(calculate_facet, true(Sparse == 8)) :-
		test_collection(Frames),
		create_object(
			sparse_calculator,
			[implements(calculator_protocol), imports(slimowl_inheritance)],
			[],
			[(calculate(Coll, Sub, sparse, V) :- frames::get_slot(Coll, Sub, spacing-S), V is S//2)]),
		frames::set_facet(calculate, sparse_calculator),
		frames::get_frame(Frames, 'Onion', [sparse-Sparse]).

	test(calculate_attrs, true(Inches-CM == 12-30.48)) :-
		test_collection(Frames),
		create_object(
			height_calculator,
			[implements(calculator_protocol), imports(slimowl_inheritance)],
			[],
			[(calculate(Coll, Sub, height(inches), H) :-
				frames::get_slot(Coll, Sub, height-H)),
			 (calculate(Coll, Sub, height(cm), V) :-
				frames::get_slot(Coll, Sub, height-H),
				V is H*2.54)]),
		frames::set_facet(calculate, height_calculator),
		frames::get_frame(Frames, 'Carrot', [height(inches)-Inches, height(cm)-CM]).

:- end_object.
