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
		create_object(
			sparse_calculator,
			[implements(reader_protocol), imports(slimowl_inheritance)],
			[],
			[(calculate(Coll, Sub, sparse, V) :- frames::get_slot(Coll, Sub, spacing-S), V is S//2)]),
		create_object(
			height_calculator,
			[implements(reader_protocol), imports(slimowl_inheritance)],
			[],
			[(calculate(Coll, Sub, height(inches), H) :-
				frames::get_slot(Coll, Sub, height-H)),
			 (calculate(Coll, Sub, height(cm), V) :-
				frames::get_slot(Coll, Sub, height-H),
				V is H*2.54)]),
		frames::set_facet(reader, inheritance_calculator).

	cleanup :-
		ignore(abolish_object(inheritance_calculator)),
		ignore(abolish_object(height_calculator)),
		ignore(abolish_object(sparse_calculator)).

	% Setting facets
	test(not_suitable, error(domain_error(protocol_relation, frames))) :-
		frames::set_facet(reader, frames).

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

	test(var_pairs, true(Sorted == [edible-leaves, subClassOf-'Plant', type-'Class'])) :-
		test_collection(Frames),
		frames::get_frame(Frames, 'Herb', Pairs),
		list::sort(Pairs, Sorted).

	% READING - Unhappy Paths
	test(no_such_slot, fail) :-
		test_collection(Frames),
		frames::get_frame(Frames, 'Carrot', [email-_Email]).

	test(no_such_frame, fail) :-
		test_collection(Frames),
		frames::get_frame(Frames, 'Ivy', [_Key-_Value]).

	test(var_collection, error(instantiation_error)) :-
		frames::get_frame(_Var, subject, [key-value]).

	% READING - Reader Facet
	test(reader_facet, true(Sparse == 8)) :-
		test_collection(Frames),
		frames::set_facet(reader, sparse_calculator),
		frames::get_frame(Frames, 'Onion', [sparse-Sparse]).

	test(calculate_attrs, true(Inches-CM == 12-30.48)) :-
		test_collection(Frames),
		frames::set_facet(reader, height_calculator),
		frames::get_frame(Frames, 'Carrot', [height(inches)-Inches, height(cm)-CM]).


	% UPDATING
	test(update_key_value, true(Updated == 1)) :-
		test_collection(Frames),
		frames::update_frame(Frames, 'Basil', [spacing-1], UpdatedFrames),
		frames::get_frame(UpdatedFrames, 'Basil', [spacing-Updated]).

	test(update_key_value_old_value, true(Updated == 1)) :-
		test_collection(Frames),
		frames::update_frame(Frames, 'Basil', [spacing-4 to 1], UpdatedFrames),
		frames::get_frame(UpdatedFrames, 'Basil', [spacing-Updated]).

	test(update_add_new_slot, true(Season == summer)) :-
		test_collection(Frames),
		frames::update_frame(Frames, 'Tomato', [growing_season-summer], UpdatedFrames),
		frames::get_frame(UpdatedFrames, 'Tomato', [growing_season-Season]).

	test(update_add_list_element, true(Sorted == ['Herb', 'NamedIndividual', 'Vegetable'])) :-
		test_collection(Frames),
		frames::update_frame(Frames, 'Onion', [subClassOf-'Herb'], UpdatedFrames),
		findall(Type, frames::get_data(UpdatedFrames, 'Onion', type-Type), Types),
		list::sort(Types, Sorted).

	test(update_change_list_element, true(Sorted == ['Herb', 'NamedIndividual'])) :-
		test_collection(Frames),
		frames::update_frame(Frames, 'Onion', [subClassOf-'Vegetable' to 'Herb'], UpdatedFrames),
		findall(Type, frames::get_data(UpdatedFrames, 'Onion', type-Type), Types),
		list::sort(Types, Sorted).

	% UPDATING - Unhappy Paths
	test(update_key_value_old_value_mismatch, fail) :-
		test_collection(Frames),
		frames::update_frame(Frames, 'Basil', [spacing-9 to 1], _UpdatedFrames).

	test(update_change_list_element_mismatch, fail) :-
		test_collection(Frames),
		frames::update_frame(Frames, 'Onion', [subClassOf-'Garlic' to 'Herb'], _UpdatedFrames).

	% DELETING
	test(delete_subject, true) :-
		test_collection(Frames),
		frames::delete_frame(Frames, 'Potato', UpdatedFrames),
		frames::subjects(UpdatedFrames, Subjects),
		\+ list::member('Potato', Subjects).

	test(delete_key_value, true) :-
		test_collection(Frames),
		frames::delete_frame(Frames, 'Potato', [spacing-_, height-_], UpdatedFrames),
		\+ frames::get_data(UpdatedFrames, 'Potato', spacing-_),
		\+ frames::get_data(UpdatedFrames, 'Potato', height-_).

	test(delete_list_element, true(Parents = ['NamedIndividual'])) :-
		test_collection(Frames),
		frames::delete_frame(Frames, 'Onion', [subClassOf-'Vegetable'], UpdatedFrames),
		findall(Class, frames::get_data(UpdatedFrames, 'Onion', [subClassOf-Class]), Parents).

	% DELETING - Unhappy Paths
	test(delete_key_value_mismatch, fail) :-
		test_collection(Frames),
		frames::delete_frame(Frames, 'Potato', [spacing-9, height-1], _UpdatedFrames).

:- end_object.
