# Frames

This is a framework for frames, in Logtalk.

## What is a frame?
Conceptually a frame is a data structure that has a subject, which is its
identity, and slots. These slots also have unique names and can contain many
values for each slot. They also support inheritence of slots.

Most often frames are used with daemons, which are additional rules that can be
queried at various points. For example, when reading a value from a slot a
"calculate" daemon may be triggered for a particular slot that will calculate
the value instead of looking it up.

Frames are useful in that they combine data with rules for knowledge
representation.

## Expected data format
This framework expects the data to be represented in SPO format, meaning:

```
{ subject: {predicate: object} }
```

Where there can be many of each subject, predicate, or object. See
`test_db.json` for an example. JSON is not required, but it does work well.

In terms of the language used, two calculation categories are provided.
`slimowl_inheritance` uses `type` to denote the slot describing
what type of thing the subject is: a 'Class', or in the case of an instance, a
'NamedIndividual' and what class it is instantiating. `subClassOf` is used for
the slot that is used for inheritence. This is to stay close to the language of
the semantic web. `classic_inheritance` uses the classic terms `isa` and `ako`
for "is a" and "a kind of", where `isa` denotes instantiation and `ako` denotes
subsumption. You can re-use these as you wish, or create your own for your
use-case and set it as a daemon.

## Adding daemons
Daemons are added as facets to `frames`. Simply choose the correct protocol,
implement it as an object, and pass that object as a facet. The test-case
`calculate_attrs` is a good example. It works like so:

```prolog
:- object(height_calculator,
	implements(calculator_protocol),
	imports(slimowl_inheritance)).

	calculate(Frames, Subject, height(inches), Height) :-
		frames::get_slot(Frames, Subject, height-Height).

	calculate(Frames, Subject, height(cm), Height) :-
		frames::get_slot(Frames, Subject, height-Inches),
		Height is Inches*2.54

:- end_object.
```

This is then added as a facet, enabling these queries:

```prolog
?- avltree::as_dictionary([reader-height_calculator], Facets),
   frames(Facets)::get_frame(TestDBFrames, 'Carrot', [height(inches)-Inches, height(cm)-CM]).

Inches = 12,
CM = 30.48 .
```

To add many kinds of calculators, such as one for units as above and perhaps
another for translation (which could be querying another frame collection in
predicate-language-value order), you might find it useful to create a
calculator interface into which you import your different kinds of calculators.
In this way you can compose sophisticated knowledge bases.

## Frame queries
By CRUD:

### Create

- Not yet

### Read

- `get_frame/3` : `get_frame(FrameCollection, Subject, [Key-Value|Pairs])`, uses
	reasoning, query many slots of a frame.

- `get_slot/3` : `get_slot(FrameCollection, Subject, Key-Value)`, uses reasoning,
	only a single slot for a frame.

- `get_data/3` : `get_data(FrameCollection, Subject, Key-Value)`, no reasoning,
	just does a lookup in the frame collection.

### Update

- WIP: Single values supported but not lists yet

### Delete

- `delete_frame/3` : `delete_frame(OldFrames, Subject, NewFrames)`, removes the
	whole frame from the collection, providing the new collection. Only deletes
	the frame, it doesn't delete references to the frame. WIP: No daemon support
	yet.
- WIP: Single values supported but not lists yet
- WIP: Purge frame, like delete frame but removing reference to it as well.
