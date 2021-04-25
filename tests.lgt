:- object(tests,
	extends(lgtunit)).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'Unit tests for Frames'
	]).

	cover(frames(_)).
	cover(slimowl_inheritance).

	:- dynamic(test_collection/1).
	:- private(test_collection/1).
	:- initialization((
		json::parse(file('test_db.json'), JSON),
		navltree::as_nested_dictionary(JSON, Dict),
		asserta(test_collection(Dict))
	)).
	:- dynamic(facet_set/2).
	:-private(facet_set/2).

	setup :-
		create_object(
			inheritance_calculator,
			[imports(slimowl_inheritance)],
			[],
			[]),
		create_object(
			sparse_calculator,
			[implements(reader_protocol), imports(slimowl_inheritance)],
			[],
			[(calculate(Coll, Fac, Sub, sparse, V) :- frames(Fac)::get_data(Coll, Sub, spacing-S), V is S//2)]),
		create_object(
			height_calculator,
			[implements(reader_protocol), imports(slimowl_inheritance)],
			[],
			[(calculate(Coll, Fac, Sub, height(inches), H) :-
				frames(Fac)::get_data(Coll, Sub, height-H)),
			 (calculate(Coll, Fac, Sub, height(cm), V) :-
				frames(Fac)::get_data(Coll, Sub, height-H),
				V is H*2.54)]),
		avltree::as_dictionary([reader-inheritance_calculator], Regular),
		avltree::as_dictionary([reader-sparse_calculator], Sparse),
		avltree::as_dictionary([reader-height_calculator], Height),
		asserta(facet_set(regular, Regular)),
		asserta(facet_set(sparse, Sparse)),
		asserta(facet_set(height, Height)).

	cleanup :-
		ignore(abolish_object(inheritance_calculator)),
		ignore(abolish_object(height_calculator)),
		ignore(abolish_object(sparse_calculator)),
		retractall(facet_set(_, _)).

	% Setting facets
	test(not_suitable, error(domain_error(protocol_relation, frames))) :-
		test_collection(Frames),
		avltree::as_dictionary([reader-frames], Facets),
		frames(Facets)::get_slot(Frames, 'Mint', edible-leaves).

	% READING
	test(plain_slots, true(Family-Spacing == 'Lily'-16)) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::get_frame(Frames, 'Onion', [family-Family, spacing-Spacing]).

	test(list_slots, true(Types == ['NamedIndividual', 'Herb'])):-
		test_collection(Frames),
		facet_set(regular, Facets),
		findall(Type, frames(Facets)::get_frame(Frames, 'Mint', [type-Type]), Types).

	test(inherited_value, true(Edible == 'leaves'), [note('Mint is a herb, herbs have edible leaves')]) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::get_frame(Frames, 'Mint', [edible-Edible]).

	test(var_pairs, true(Sorted == [edible-leaves, subClassOf-'Plant', type-'Class'])) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::get_frame(Frames, 'Herb', Pairs),
		list::sort(Pairs, Sorted).

	% READING - Unhappy Paths
	test(no_such_slot, fail) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::get_frame(Frames, 'Carrot', [email-_Email]).

	test(no_such_frame, fail) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::get_frame(Frames, 'Ivy', [_Key-_Value]).

	test(var_collection, error(instantiation_error)) :-
		facet_set(regular, Facets),
		frames(Facets)::get_frame(_Var, subject, [key-value]).

	% READING - Reader Facet
	test(reader_facet, true(Sparse == 8)) :-
		test_collection(Frames),
		facet_set(sparse, Facets),
		frames(Facets)::get_frame(Frames, 'Onion', [sparse-Sparse]).

	test(calculate_attrs, true(Inches-CM == 12-30.48)) :-
		test_collection(Frames),
		facet_set(height, Facets),
		frames(Facets)::get_frame(Frames, 'Carrot', [height(inches)-Inches, height(cm)-CM]).


	% UPDATING
	test(update_key_value, true(Updated == 1)) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::update_frame(Frames, 'Basil', [spacing-1], UpdatedFrames),
		frames(Facets)::get_frame(UpdatedFrames, 'Basil', [spacing-Updated]).

	test(update_key_value_old_value, true(Updated == 1)) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::update_frame(Frames, 'Basil', [spacing-4 to 1], UpdatedFrames),
		frames(Facets)::get_frame(UpdatedFrames, 'Basil', [spacing-Updated]).

	test(update_add_new_slot, true(Season == summer)) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::update_frame(Frames, 'Tomato', [growing_season-summer], UpdatedFrames),
		frames(Facets)::get_frame(UpdatedFrames, 'Tomato', [growing_season-Season]).

	test(update_add_list_element, true(Sorted == ['Herb', 'NamedIndividual', 'Vegetable'])) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::update_frame(Frames, 'Onion', [subClassOf-'Herb'], UpdatedFrames),
		findall(Type, frames(Facets)::get_data(UpdatedFrames, 'Onion', type-Type), Types),
		list::sort(Types, Sorted).

	test(update_change_list_element, true(Sorted == ['Herb', 'NamedIndividual'])) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::update_frame(Frames, 'Onion', [subClassOf-'Vegetable' to 'Herb'], UpdatedFrames),
		findall(Type, frames(Facets)::get_data(UpdatedFrames, 'Onion', type-Type), Types),
		list::sort(Types, Sorted).

	% UPDATING - Unhappy Paths
	test(update_key_value_old_value_mismatch, fail) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::update_frame(Frames, 'Basil', [spacing-9 to 1], _UpdatedFrames).

	test(update_change_list_element_mismatch, fail) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::update_frame(Frames, 'Onion', [subClassOf-'Garlic' to 'Herb'], _UpdatedFrames).

	% DELETING
	test(delete_subject, true) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::delete_frame(Frames, 'Potato', UpdatedFrames),
		frames(Facets)::subjects(UpdatedFrames, Subjects),
		\+ list::member('Potato', Subjects).

	test(delete_key_value, true) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::delete_frame(Frames, 'Potato', [spacing-_, height-_], UpdatedFrames),
		\+ frames(Facets)::get_data(UpdatedFrames, 'Potato', spacing-_),
		\+ frames(Facets)::get_data(UpdatedFrames, 'Potato', height-_).

	test(delete_list_element, true(Parents = ['NamedIndividual'])) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::delete_frame(Frames, 'Onion', [subClassOf-'Vegetable'], UpdatedFrames),
		findall(Class, frames(Facets)::get_data(UpdatedFrames, 'Onion', [subClassOf-Class]), Parents).

	% DELETING - Unhappy Paths
	test(delete_key_value_mismatch, fail) :-
		test_collection(Frames),
		facet_set(regular, Facets),
		frames(Facets)::delete_frame(Frames, 'Potato', [spacing-9, height-1], _UpdatedFrames).

:- end_object.
