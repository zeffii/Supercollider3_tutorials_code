/*

           SuperCollider Tutorial: 12. Nintendo Wiimote
           https://www.youtube.com/watch?v=JRIUq-46V6M

           Following along, but just the code for the synthdef and nuggets of wisdom

*/


(
SynthDef.new(\foldsaw, {
	arg freq=4, detune=1, out=0, amp=0, boost=1.23,
	atk=0.01, dec=0.3, rel=3, gate=1,
	c1=1, c2=(-1),
	mincf=40, maxcf=12000,    // cut off frequency
	minrq=0.002, maxrq=0.2;   // resonance quality

	var sig, env;

	env = EnvGen.kr(Env.adsr(atk, dec, 0.5, rel), gate, doneAction:2);
	sig = Saw.ar(
		freq *
		LFNoise1.kr(LFNoise1.kr(0.5!8).range(0.1, 1)).bipolar(detune)
	);
	5.do(sig = (sig * boost).fold(-1.0, 1.0)); // fold acts as a mirror
	sig = BPF.ar(
		sig,
		LFNoise1.kr((ExpRand(0.005, 0.05))!8).exprange(mincf, maxcf),
		LFNoise1.kr((ExpRand(0.1, 0.75))!8).range(minrq, maxrq),
	);
	sig = Splay.ar(sig) * env * amp * 2;
	Out.ar(out, sig);
}).add;
)

x = Synth.new(\foldsaw);  // default args
x.set(\freq, 50);
x.set(\amp, 0.9);
x.set(\gate, 0);  // to release