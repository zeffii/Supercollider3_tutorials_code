// Collections is a parent of many useful classes.

// prints hello n times, and the returns the array
[6,3,5,2,6,7,4,5].do{"hello".postln};

// takes item from array and prints its square
(
[6,3,5,2,6,7,4,5].do{
	arg item;
	item.squared.postln;
}
)


// takes item from array and prints its square
// also shows the current count or index
(
[6,3,5,2,6,7,4,5].do{
	arg item, count;
	[count, item.squared].postln;
}
)

// updating the array, or making a new to hold update values
(
x = Array.newClear(8);
[6,3,5,2,6,7,4,5].do{
	arg item, count;
	x[count] = item.squared;
}
)

x;

// .collect returns a new array instead of the original like .do does

(
z = [2,3,4,5,6,7].collect{
	arg item;
	item.squared;}
)
z;

// or super condensed syntactic sugar using parens. and underscore
z = [2,3,4,5,6,7].collect(_.squared);

// do
[0,1,2,3,4].do;
// same..
5.do;  // just posts last element 5..but does it 5 times

[0,1,2,3,4].do{arg item; item.postln};
5.do{arg item; item.postln};

x = {VarSaw.ar(40!2, 0, 0.05)}.play;
/// simple saw
x.free;


// super saw, notice click they all start at 0 phase
(SynthDef.new(\iter, {
	var temp, sum;
	sum = 0;
	10.do{
		temp = VarSaw.ar(
			40 * {Rand(0.99, 1.02)}!2,
			0,
			0.05
		);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter);
x.free;

// super saw, offset each waveform phase to avoid click
// this almost gets rid of that, but it is still random...so can click
(SynthDef.new(\iter, {
	var temp, sum;
	sum = 0;
	10.do{
		temp = VarSaw.ar(
			40 * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			0.05
		);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter);
x.free;

// super saw, as before but randomized the duty cycle too
(SynthDef.new(\iter, {
	var temp, sum;
	sum = 0;
	10.do{
		temp = VarSaw.ar(
			40 * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			{ExpRand(0.005, 0.05)}!2
		);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter);
x.free;

// adding a doneAction helps avoid having to 'free' these synths.
// super saw, as before but randomized the duty cycle too
(SynthDef.new(\iter, {
	var temp, sum, env;
	sum = 0;
	env = EnvGen.kr(
		Env.perc(0.01, 5, 1, -2),
		doneAction:2
	);
	10.do{
		temp = VarSaw.ar(
			40 * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			{ExpRand(0.005, 0.05)}!2
		);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0, sum);
}).add;
)

Synth.new(\iter);

// now add a freq argument.
// adding a doneAction helps avoid having to 'free' these synths.
// super saw, as before but randomized the duty cycle too
(SynthDef.new(\iter, {
	arg freq=40;
	var temp, sum, env;
	sum = 0;
	env = EnvGen.kr(
		Env.perc(0.01, 5, 1, -2),
		doneAction:2
	);
	10.do{
		temp = VarSaw.ar(
			freq * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			{ExpRand(0.005, 0.05)}!2
		);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0, sum);
}).add;
)

Synth.new(\iter, [\freq, 400]);
Synth.new(\iter, [\freq, 300]);
Synth.new(\iter, [\freq, 250]);
Synth.new(\iter, [\freq, 224]);

// the following wrks but is discouraged

// play multiple at the same time.
(
[400, 300, 250].do{
	arg item;
	Synth.new(\iter, [\freq, item]);
}
)

// use midicps
(
[41, 44, 48].do{
	arg item;
	Synth.new(\iter, [\freq, item.midicps]);
}
)


// bulding the loop into the ugen, this is what Blip Ugen does
// under the hood
(
SynthDef.new(\iter2, {
	arg freq=200;
	var temp, sum;
	sum=0;
	10.do{
		arg count;
		temp = SinOsc.ar(
			freq * (count+1));
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter2);
x.free;


// bulding the loop into the ugen, this is what Blip Ugen does
// under the hood ---- but here overtones can meander slightly
// plus multi channel expansion.
(
SynthDef.new(\iter2, {
	arg freq=200;
	var temp, sum;
	sum=0;
	10.do{
		arg count;
		temp = SinOsc.ar(
			freq *
			(count+1) *
			LFNoise1.kr({Rand(0.08, 0.2)}!2).range(0.98, 1.02)
		) ;
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter2);
x.free;

// bulding the loop into the ugen, this is what Blip Ugen does
// under the hood ---- but here overtones can meander slightly
// plus multi channel expansion.
// plus amplitude of each partial fluctuates randomly
(
SynthDef.new(\iter2, {
	arg freq=200;
	var temp, sum;
	sum=0;
	10.do{
		arg count;
		temp = SinOsc.ar(
			freq *
			(count+1) *
			LFNoise1.kr({Rand(0.08, 0.2)}!2).range(0.98, 1.02)
		) ;
		temp = temp * LFNoise1.kr({Rand(0.5, 8)}!2).exprange(0.01,1);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter2);
x.free;

// because we declared an argument we can also set frequency
x.set(\freq, 120);

// Using reciprocel method 'deviation'

(
SynthDef.new(\iter3, {
	arg freq=200, dev=1.02;
	var temp, sum;
	sum=0;
	10.do{
		arg count;
		temp = SinOsc.ar(
			freq *
			(count+1) *
			LFNoise1.kr({Rand(0.08, 0.2)}!2).range(dev.reciprocal, dev)
		) ;
		temp = temp * LFNoise1.kr({Rand(0.5, 8)}!2).exprange(0.01,1);
		sum = sum + temp;
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth.new(\iter3);
x.set(\dev, 1.3);
x.free;













