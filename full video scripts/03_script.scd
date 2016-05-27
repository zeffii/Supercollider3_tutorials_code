Hey everyone, welcome to tutorial number 3. In the previous video we started making sound by creating a UGen function and sending it the "play" message. This process creates a Synth, which represents a single sound-producing unit on the audio server. However, the primary and more flexible procedure for creating sound is to first create a SynthDef and then execute the SynthDef by calling a Synth explicitly. A SynthDef is essentially a recipe for a particular sound, and a Synth is the execution of that recipe. As we can see in the help file for Function,

"Function.play is often more convienent than SynthDef.play, particularly for short examples and quick testing. But where reuse and maximum flexibility are of greater importance, SynthDef and its various methods are usually the better choice."

Likewise, in the SynthDef help file we see that "Methods such as Function-play, etc. are simply conveniences which automatically create a SynthDef"

To demonstrate, I'll take our UGen function from the previous tutorial and convert it to a SynthDef.

s.boot;

(
z = {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) * amp;
}.play
)

As is the case with many objects in SuperCollider, we create a new instance using the "new" message. "new," in this case, takes 6 arguments, but generally, you'll only specify values for the first two arguments, name and ugenGraphFunc.

The first argument is the name you want to give to your SynthDef, which can be specified as either a string...or a symbol. I prefer the symbol because it's one less character I have to type.

The second argument is a UGen function, which is nearly identical to our function from above, so we can pretty much copy and paste. However, there's one additional thing to consider when building a SynthDef. If you want this SynthDef to output a signal, you must include an output UGen. The most basic of these UGens is simply called Out. Out needs an output bus index, and the signal to write to that bus. I'll deal with inputs, outputs, and busses in a future tutorial since there's a lot of information to cover, so for now, I'll just say that the audio bus with index 0 corresponds to your lowest-numbered hardware audio output. Audio bus 1 corresponds to the next-highest hardware output, and so on, until you run out of hardware outputs. So in the case of most laptop sound cards, this means audio bus 0 corresponds to your left speaker, and audio bus 1 corresponds to your right speaker.

We'll close out the SynthDef, and the last thing we need to do is "add" the new SynthDef, which sends it to the audio server so that it can be used. There are other methods to make a SynthDef usable, such as load, send, and store, but add is probably the most flexible.

(
SynthDef.new(\sineTest, {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) * amp;
	Out.ar(0, sig);
}).add
)

To execute the SynthDef, we create a new Synth and provide it with the name of a SynthDef.

x = Synth.new(\sineTest);

We terminate the Synth using the free method, just like we've done in the previous tutorial.

x.free;

The SynthDef above has one argument, noiseHz, whose default value is 8. If I wanted to create a Synth that starts with a different value for noiseHz, I can add a second argument to Synth.new. This is an array that contains the symbolic name of the argument, followed by a comma, and the value.

x = Synth.new(\sineTest, [\noiseHz, 32])

As we saw in the previous tutorial, the set message can be used to update control arguments while the Synth is active.

x.set(\noiseHz, 12)

x.free;

In the Synth help file, notice that the "new" method actually takes four arguments. In addition to the SynthDef name and argument array, there's also target and addAction. These are useful, but not relevant right now, so I'll deal with them in a tutorial down the road. For now it's fine to use the default values for target and addAction.

Before I close out this video, I'll code another SynthDef from scratch to reinforce concepts.

I'll call this one pulseTest.

(
SynthDef.new(\pulseTest, {

}).add;
)

I'll send one signal to the left speaker, and another to the right speaker.

(
SynthDef.new(\pulseTest, {
	var sig1, sig2;
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

I'll use pulse waves for both audio signals.

(
SynthDef.new(\pulseTest, {
	var sig1, sig2;
	sig1 = Pulse.ar();
	sig2 = Pulse.ar();
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

I'll control the frequency of these pulse waves with non-interpolated noise, with a new value chosen 4 times per second. LFNoise0 is a randm value generator, so even though I'm using the same UGen twice, they will both generate a unique stream of values.

(
SynthDef.new(\pulseTest, {
	var sig1, sig2, freq1, freq2;
	freq1 = LFNoise0.kr(4).exprange();
	freq2 = LFNoise0.kr(4).exprange();
	sig1 = Pulse.ar();
	sig2 = Pulse.ar();
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

I want to be able to change the frequency as the Synth is playing, so I'll create some arguments. I'll define a fundamental frequency and a maximum partial number, and have LFNoise range between them.

(
SynthDef.new(\pulseTest, {
	arg fund=40, maxPartial=4;
	var sig1, sig2, freq1, freq2;
	freq1 = LFNoise0.kr(4).exprange(fund, fund * maxPartial);
	freq2 = LFNoise0.kr(4).exprange(fund, fund * maxPartial);
	sig1 = Pulse.ar();
	sig2 = Pulse.ar();
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

And I'll introduce a message we haven't seen yet, called "round", which simply rounds the output to the nearest multiple of a number. So in this case, LFNoise0 will output random overtones of a given fundamental.

(
SynthDef.new(\pulseTest, {
	arg fund=40, maxPartial=4;
	var sig1, sig2, freq1, freq2;
	freq1 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	sig1 = Pulse.ar();
	sig2 = Pulse.ar();
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

Just for a little extra subtlety, I'll use LFPulse to add some octave jumps. LFPulse normally ranges from 0 to 1, so I'll add 1 in order to have it range from 1 to 2. And I'm just using different frequency values here for the sake of variety.

(
SynthDef.new(\pulseTest, {
	arg fund=40, maxPartial=4;
	var sig1, sig2, freq1, freq2;
	freq1 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq1 = freq1 * LFPulse.kr(8)+1;
	freq2 = freq2 * LFPulse.kr(6)+1;
	sig1 = Pulse.ar();
	sig2 = Pulse.ar();
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

I'll use LFPulse again to control the amplitude and transform what would otherwise be a steady tone into regular pulses of sound. I'll specify a duty cycle that's close to zero, so that the pulses are fairly short. I'll set the phase of the 2nd amplitude control to 0.5 so that the two pulse waves are out of phase with one another. This way, the sound will alternate between the left and right speakers. And, I'll also multiply by 0.75 just to take down the volume a bit.

(
SynthDef.new(\pulseTest, {
	arg fund=40, maxPartial=4;
	var amp1, amp2, sig1, sig2, freq1, freq2;
	amp1 = LFPulse.kr(4,0,0.12) * 0.75;
	amp2 = LFPulse.kr(4,0.5,0.12) * 0.75;
	freq1 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq1 = freq1 * LFPulse.kr(8)+1;
	freq2 = freq2 * LFPulse.kr(6)+1;
	sig1 = Pulse.ar();
	sig2 = Pulse.ar();
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

In fact, let's use another argument for the amplitude pulse frequency.

(
SynthDef.new(\pulseTest, {
	arg ampHz=4, fund=40, maxPartial=4;
	var amp1, amp2, sig1, sig2, freq1, freq2;
	amp1 = LFPulse.kr(ampHz,0,0.12) * 0.75;
	amp2 = LFPulse.kr(ampHz,0.5,0.12) * 0.75;
	freq1 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq1 = freq1 * LFPulse.kr(8)+1;
	freq2 = freq2 * LFPulse.kr(6)+1;
	sig1 = Pulse.ar();
	sig2 = Pulse.ar();
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

I'll add one last argument for the width of the pulse wave output, and fill in the parentheses at the bottom.

(
SynthDef.new(\pulseTest, {
	arg ampHz=4, fund=40, maxPartial=4, width=0.5;
	var amp1, amp2, sig1, sig2, freq1, freq2;
	amp1 = LFPulse.kr(ampHz,0,0.12) * 0.75;
	amp2 = LFPulse.kr(ampHz,0.5,0.12) * 0.75;
	freq1 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq1 = freq1 * LFPulse.kr(8)+1;
	freq2 = freq2 * LFPulse.kr(6)+1;
	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

Last, I'll add some reverb using FreeVerb to make it sound nice.

(
SynthDef.new(\pulseTest, {
	arg ampHz=4, fund=40, maxPartial=4, width=0.5;
	var amp1, amp2, sig1, sig2, freq1, freq2;
	amp1 = LFPulse.kr(ampHz,0,0.12) * 0.75;
	amp2 = LFPulse.kr(ampHz,0.5,0.12) * 0.75;
	freq1 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund * maxPartial).round(fund);
	freq1 = freq1 * (LFPulse.kr(8)+1);
	freq2 = freq2 * (LFPulse.kr(6)+1);
	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);
	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

Let's give it a try.

x = Synth.new(\pulseTest);

We can change the width

x.set(\width, 0.05);
x.set(\width, 0.25);

the fundamental frequency

x.set(\fund, 50);
x.set(\fund, 60);
x.set(\fund, 80);
x.set(\fund, 160);
x.set(\fund, 30);

The maximum partial number

x.set(\maxPartial, 8);
x.set(\maxPartial, 20);

And last, we can change the rate of amplitude pulsing

x.set(\ampHz, 2);
x.set(\ampHz, 1);
x.set(\ampHz, 0.25);

x.free;

If I want to initialize this Synth with arguments that are different from the default values, I can do so by providing an array of symbol-value pairs as Synth's second argument, like this

x = Synth.new(\pulseTest, [\ampHz, 3.3, \fund, 48, \maxPartial, 4, \width, 0.15]);

x.free;

That's it for tutorial number 3. From this point on, I'll use function.play for short simple examples, and SynthDef for more complicated examples. Stay tuned for number 4, where I'll talk about envelopes and doneActions. Thanks for watching!