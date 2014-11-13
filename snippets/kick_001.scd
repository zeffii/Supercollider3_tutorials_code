/*
   Experiments 1

   KickDrums

*/

s.boot;
s.plotTree;

(
SynthDef.new(\kick2, {
	arg freq=150, dur=0.9, slope=3, amp=0.3, pan=0;
 	var sig, env, out=0;
	env = EnvGen.kr(Env.new(
 		[1, 0.4, 0.2, 0],
 		[0.02, 0.6, 1.2],
		[slope, slope.neg, -5]), 1, doneAction:2);
 	sig = SinOsc.ar(freq*env, 0, env);
 	Out.ar(out, Pan2.ar(sig*env, pan, amp));
}).add;
)

m = Synth.new(\kick2, [\amp, 0.9]);
