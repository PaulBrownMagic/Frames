:- initialization((
	logtalk_load([
		nested_dictionaries(loader),
		sets(loader)
	]),
	logtalk_load([
		calculate_protocol,
		frames
	],
	[
		optimize(on)
	])
)).

:- if(current_logtalk_flag(events, allow)).
:- initialization((
	logtalk_load([
		daemon_protocols,
		frames_monitor
	],
	[
		optimize(on)
	]),
	define_events(after, frames, add_frame(_, _, _, _), _, frames_monitor),
	define_events(after, frames, update_frame(_, _, _, _), _, frames_monitor),
	define_events(after, frames, delete_frame(_, _, _, _), _, frames_monitor),
	define_events(after, frames, delete_frame(_, _, _), _, frames_monitor),
	logtalk::print_message(information, frames, ['Loaded frames with daemons (events allowed)'])
)).

:- else.

:- initialization((
	logtalk::print_message(information, frames, ['Loaded frames without daemons (events not allowed)'])
)).

:- endif.
