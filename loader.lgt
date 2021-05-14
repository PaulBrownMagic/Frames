:- initialization((
	logtalk_load([
		nested_dictionaries(loader),
		sets(loader)
	]),
	logtalk_load([
		daemon_protocols,
		frames
	],
	[
		optimize(on)
	])
)).

