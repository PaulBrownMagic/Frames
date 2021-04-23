:- protocol(calculator_protocol).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'Protocol for objects that implement the calculate facet'
	]).

	:- public(calculate/4).
	:- mode(calculate(++nested_dictionary, ++atomic, ?atomic, ?term), zero_or_more).
	:- info(calculate/4, [
		comment is 'For the given ``Frames`` and ``Subject``, calculate the ``Value`` of the ``Slot``',
		arguments is [
			'Frames'-'A Nested Dictionary of Frames',
			'Subject'-'The Frame subject',
			'Slot'-'The name of the slot to calculate',
			'Value'-'The value to calculate'
		]
	]).

:- end_protocol.
