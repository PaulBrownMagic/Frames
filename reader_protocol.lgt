:- protocol(reader_protocol).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'Protocol for objects that implement the calculate facet on read'
	]).

	:- public(calculate/5).
	:- mode(calculate(++nested_dictionary, ++dictionary, ?atomic, ?atomic, ?term), zero_or_more).
	:- info(calculate/5, [
		comment is 'For the given ``Frames``, ``Facets``, and ``Subject``, calculate the ``Value`` of the ``Slot``',
		arguments is [
			'Frames'-'A Nested Dictionary of Frames',
			'Facets'-'The dictionary of facets currently in use by frames',
			'Subject'-'The Frame subject',
			'Slot'-'The name of the slot to calculate',
			'Value'-'The value to calculate'
		]
	]).

:- end_protocol.
