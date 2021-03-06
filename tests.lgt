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
			[implements(calculate_protocol)],
			[],
			[(calculate(Coll, Sub, sparse, V) :- frames::get_data(Coll, Sub, spacing-S), V is S//2)]),
		create_object(
			height_calculator,
			[implements(calculate_protocol)],
			[],
			[(calculate(Coll, Sub, height(inches), H) :-
				frames::get_data(Coll, Sub, height-H)),
			 (calculate(Coll, Sub, height(cm), V) :-
				frames::get_data(Coll, Sub, height-H),
				V is H*2.54)]).

	cleanup :-
		ignore(abolish_object(inheritance_calculator)),
		ignore(abolish_object(height_calculator)),
		ignore(abolish_object(sparse_calculator)).

	% READING
	test(plain_slots, true(Family-Spacing == 'Lily'-16)) :-
		test_collection(Frames),
		frames::get_frame(
			Frames,
			'Onion',
			[family-Family,
			spacing-Spacing]).

	test(list_slots, true(Types == ['Herb', 'NamedIndividual'])):-
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
		frames::get_frame(Frames, 'Onion', [sparse-Sparse]).

	test(calculate_attrs, true(Inches-CM == 12-30.48)) :-
		test_collection(Frames),
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

	test(update_key_value_old_value_bracketed, true(Updated == 1)) :-
		test_collection(Frames),
		frames::update_frame(Frames, 'Basil', [spacing-(4 to 1)], UpdatedFrames),
		frames::get_frame(UpdatedFrames, 'Basil', [spacing-Updated]).

	test(update_change_list_element, true(Sorted == ['Herb', 'NamedIndividual'])) :-
		test_collection(Frames),
		frames::update_frame(Frames, 'Onion', [type-'Vegetable' to 'Herb'], UpdatedFrames),
		findall(Type, frames::get_data(UpdatedFrames, 'Onion', type-Type), Types),
		list::sort(Types, Sorted).

	% UPDATING - Unhappy Paths
	test(update_key_value_old_value_mismatch, fail) :-
		test_collection(Frames),
		frames::update_frame(Frames, 'Basil', [spacing-9 to 1], _UpdatedFrames).

	test(update_change_list_element_mismatch, fail) :-
		test_collection(Frames),
		frames::update_frame(Frames, 'Onion', [type-'Garlic' to 'Herb'], _UpdatedFrames).

	test(update_change_list_element_var_oldvalue, fail) :-
		test_collection(Frames),
		frames::update_frame(Frames, 'Onion', [type-_Var to 'Herb'], _UpdatedFrames).

	% DELETING
	test(delete_subject, true) :-
		test_collection(Frames),
		frames::delete_frame(Frames, 'Potato', UpdatedFrames),
		frames::subjects(UpdatedFrames, Subjects),
		\+ list::member('Potato', Subjects).

	test(delete_key_value, true) :-
		test_collection(Frames),
		frames::delete_frame(Frames, 'Potato', [spacing-4, height-_], UpdatedFrames),
		\+ frames::get_data(UpdatedFrames, 'Potato', spacing-_),
		\+ frames::get_data(UpdatedFrames, 'Potato', height-_).

	test(delete_list_element, true(Parents = ['NamedIndividual'])) :-
		test_collection(Frames),
		frames::delete_frame(Frames, 'Onion', [type-'Vegetable'], UpdatedFrames),
		findall(Class, frames::get_data(UpdatedFrames, 'Onion', type-Class), Parents).

	test(delete_element_unifies, true(Spacing == 4)) :-
		test_collection(Frames),
		frames::delete_frame(Frames, 'Potato', [spacing-Spacing], _).

	% DELETING - Unhappy Paths
	test(delete_key_value_mismatch, fail) :-
		test_collection(Frames),
		frames::delete_frame(Frames, 'Potato', [spacing-9, height-1], _UpdatedFrames).

	test(delete_var_subject, fail) :-
		test_collection(Frames),
		frames::delete_frame(Frames, _Potato, [spacing-9, height-1], _UpdatedFrames).

	test(delete_var_key, fail) :-
		test_collection(Frames),
		frames::delete_frame(Frames, 'Potato', [_spacing-9, height-1], _UpdatedFrames).

	test(delete_var_value, fail) :-
		test_collection(Frames),
		frames::delete_frame(Frames, 'Potato', [spacing-_Var, height-1], _UpdatedFrames).

	% ADDING
	test(add_new_frame_subject, true) :-
		test_collection(Frames),
		frames::add_frame(Frames, 'Rosemary', [], Updated),
		frames::subjects(Updated, Subjects),
		list::memberchk('Rosemary', Subjects).

	test(add_new_frame_slots, true([Spacing, Height] == [1, 12])) :-
		test_collection(Frames),
		frames::add_frame(Frames, 'Rosemary', [spacing-1, height-12], Updated),
		frames::get_frame(Updated, 'Rosemary', [spacing-Spacing, height-Height]).

	test(add_new_slot, true(Season == summer)) :-
		test_collection(Frames),
		frames::add_frame(Frames, 'Tomato', [growing_season-summer], UpdatedFrames),
		frames::get_frame(UpdatedFrames, 'Tomato', [growing_season-Season]).

	test(add_dup_slot, true(Length == 2)) :-
		test_collection(Frames),
		frames::add_frame(Frames, 'Onion', [type-'Vegetable'], UpdatedFrames),
		findall(Type, frames::get_data(UpdatedFrames, 'Onion', type-Type), Types),
		list::length(Types, Length).

	test(update_add_list_element, true(Sorted == ['Herb', 'NamedIndividual', 'Vegetable'])) :-
		test_collection(Frames),
		frames::add_frame(Frames, 'Onion', [type-'Herb'], UpdatedFrames),
		findall(Type, frames::get_data(UpdatedFrames, 'Onion', type-Type), Types),
		list::sort(Types, Sorted).

	test(add_already_exists_ignore, true(Frames == UpdatedFrames)) :-
		test_collection(Frames),
		frames::add_frame(Frames, 'Carrot', [height-12], UpdatedFrames).

	% Adding - Unhappy Paths
	test(add_var_subject, fail) :-
		test_collection(Frames),
		frames::add_frame(Frames, _Potato, [spacing-9, height-1], _UpdatedFrames).

	test(add_var_key, fail) :-
		test_collection(Frames),
		frames::add_frame(Frames, 'Potato', [_spacing-9, height-1], _UpdatedFrames).

	test(add_var_value, fail) :-
		test_collection(Frames),
		frames::add_frame(Frames, 'Potato', [spacing-_Var, height-1], _UpdatedFrames).


:- end_object.
