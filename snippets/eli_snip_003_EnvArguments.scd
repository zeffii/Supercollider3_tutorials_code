/*

           SuperCollider Tutorial: 4. Envelopes and doneAction
           https://www.youtube.com/watch?v=-wDAPo9hpCg

           this snippet is by no means complete.

*/

s.boot;
s.plotTree;   // you want to see which synths are present on the server

// evaluate this blok once, and you'll see a Synth on the plotTree;
// plotTree might show: Synth("temp__0" : 1000)
(
x = {
	var sig, env;
	env = Line.kr(1, 0, 1);
	sig = Pulse.ar(ExpRand(30, 500)) * env;

}.play;
)

// you notice the synth stays on the server as it is still visible on
// the plotTree, even if we don't hear it. Because we just have one synth, we can
// stop the synth by accessing the variable we assigned it to; x
x.free;

/*
   however, if you evaluate the the blok several times without first freeing
   the existing synths then the plotTree might look like this:

     Synth("temp__0" : 1000)
     Synth("temp__1" : 1001)
     Synth("temp__2" : 1002)
     Synth("temp__3" : 1003)
     Synth("temp__4" : 1004)

   they are all still on the server, even when they can't be heard.
   > the synth is still running , and it is outputting 0s at the audio rate, which means
   > it's still using cpu cycles.
*/

// By assigning to the same x each time we evaluated we lost references to the preceding
// synth. Now if we want to free the synths we're stuck, we can only stop the last synth
// using x.free.
x.free;

// In this scenario the simplest way to kill the synths is to detache all synths on the server
s.freeAll;  // this is quite drastic because it will free all synths and groups on the server.
            // or cmd + period / ctrl+period


/*
    doneAction (see docs)
    this action allows us to free a synth depending on a given cue

    below, when EnvGen is completed, doneAction: 2 will remove the synth from the server.
    You'll see it appear on the plotTree and then vanish when it ends.

*/

(
{
	var sig, env;
	env = EnvGen.kr(Env.new, doneAction:2);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play
)

// here the shorted duration is 1 second, and this doesn't give freq XLine enough
// time to complete the change from 880 to 110.
// > Whichever XLine finishes first, will free the synth.

(
{
	var sig, freq, env;
	env = XLine.kr(1, 0.01, 1, doneAction:2);
	freq = XLine.kr(880, 110, 5, doneAction:2);
	sig = Pulse.ar(freq) * env;
}.play;
)

// > reversing the roles, the env never has time to fade out to 0.01
(
{
	var sig, freq, env;
	env = XLine.kr(1, 0.01, 5, doneAction:2);
	freq = XLine.kr(880, 110, 1, doneAction:2);
	sig = Pulse.ar(freq) * env;
}.play;
)

// the remedy is to change the doneAction on the shorter XLine to 0
// which is the same as not supplying doneAction at all to that XLine
// > since the default value of doneAction is 0.
(
{
	var sig, freq, env;
	env = XLine.kr(1, 0.01, 5, doneAction:2);
	freq = XLine.kr(880, 110, 1, doneAction:0);
	sig = Pulse.ar(freq) * env;
}.play;
)



/*
    Envelopes and Lines

*/

// Lets provide our own envelope.
// note 3rd argument controls the strength of the curvature
Env.new([0, 1, 0.2, 0], [0.5, 1, 2]).plot;
Env.new([0, 1, 0.2, 0], [0.5, 1, 2], [3, -1, 0]).plot;
Env.new([0, 1, 0.2, 0], [0.5, 1, 2], [13, -11, 0]).plot;


// altogether

(
{
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0, 1, 0.2, 0],
		[0.5, 1, 2],
		[3, -1, 0]),
		doneAction:2);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play
)

// using Env's Gate argument
(
x = {
	arg gate=0;
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0, 1, 0.2, 0],
		[0.5, 1, 1.2],
		[3, -1, 0]), gate);
	sig = Pulse.ar(LFPulse.kr(6).range(600,900)) * env;
}.play
)

x.set(\gate, 1);

// or built in retrig arg called `t_` prefix
// which resets the value to 0 after a control cycle.
(
x = {
	arg t_gate=1;
	var sig, env;
	env = EnvGen.kr(Env.new(
		[0, 1, 0.2, 0],
		[0.5, 1, 1.2],
		[3, -1, 0]), t_gate);
	sig = Pulse.ar(LFPulse.kr(6).range(600,900)) * env;
}.play
)

x.set(\t_gate, 1);
x.free;
s.freeAll;


///// cool sounds

(
x = {
	arg gate=0;
	var sig, env, freq;
	freq = EnvGen.kr(Env.adsr(1), gate, 200, 0.1);
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = VarSaw.ar(SinOsc.kr(freq).range(500,1000)) * env;
}.play;
)

x.set(\gate, 1);   // trigger
x.set(\gate, 0);   // release

//// read Env File!


