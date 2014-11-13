/*

           SuperCollider Tutorial: 4. Envelopes and doneAction

           https://www.youtube.com/watch?v=-wDAPo9hpCg

*/

s.boot;
s.plotTree;   // you want to see which synths are present on the server

// evaluate this line once, and you'll see a Synth on the plotTree;
x = {PinkNoise.ar * 0.5}.play;    // plotTree might show: Synth("temp__0" : 1000)

// because we just have one synth, we can stop the pinknoise by accessing the variable x
x.free;

// however, if you evaluate the pinknoise several times without first freeing the existing sounds
x = {PinkNoise.ar * 0.1}.play;   // evaluate this line a few times.

/*
plotTree might look like this:
     Synth("temp__0" : 1000)
     Synth("temp__1" : 1001)
     Synth("temp__2" : 1002)
     Synth("temp__3" : 1003)
     Synth("temp__4" : 1004)
*/

// By assigning to the same x each time we evaluate we lose references to the preceding
// synth assigned to x. Now if we want to free the synths, we can only stop the last
// synth using x.free.
x.free;

// In this scenario the simplest way to kill the synths is to detache all synths on the server
s.freeAll;  // this is quite drastic because it will also free (wanted) synths and groups on the server.




// Env Arguments
(
{
	var sig, env;
	env = EnvGen.kr(Env.new, doneAction:2);
	sig = Pulse.ar(ExpRand(30, 500)) * env;
}.play
)

// Lets provide our own
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


