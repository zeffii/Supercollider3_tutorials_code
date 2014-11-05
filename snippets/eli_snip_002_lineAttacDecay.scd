// using line for adsr, not synth stays alive but produces no sound

(
x = {
	var sig, env;
	env = Line.kr(1,0,1);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)

// x.free;  will only free the last x.
// would need to x.freeAll;

// free it. we named it because we needed to free it.
(
{
	var sig, env;
	env = Line.kr(1,0,1, doneAction:2);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play;
)

//// test 3 using XLine
// use doneAction on the longest Line
// else it cuts off early
(
{
	var sig, freq, env;
	env = XLine.kr(1, 0.01, 1, doneAction:2);
	freq = XLine.kr(600, 110, 1, doneAction:2);
	sig = Pulse.ar(freq) * env;
}.play;
)

0.125.ampdb;