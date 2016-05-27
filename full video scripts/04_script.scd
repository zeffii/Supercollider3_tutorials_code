s.boot;

Hey everyone, welcome to tutorial number 4. So far, all the sound we've been producing is generated indefinitely until we either free the Synth or press command period.

x = {PinkNoise.ar * 0.5}.play
x.free;

But both of these options are hard stops: they release the sound instantaneously and usually produce a click. There are many cases when you'd want a Synth to fade in and fade out, and to free itself after the fade out is complete instead of the user having to free the Synth manually. For this purpose, there are several envelope UGens available, which we can find in the Documentation by going to Browse...UGens...and Envelopes. The term 'envelope' in many cases refers to the well-known "adsr" envelope, which I'll discuss later in this video, but there are many kinds of envelopes. More generally, 'envelope' refers to a custom signal shape that controls one or more parameters of a sound. Envelopes most often control amplitude, but they can just as easily control other parameters, like frequency, duty cycle, playback speed, etc.

Let's start by looking at Line, which is the simplest of these envelopes.\

Line.kr();

Line takes a start value, an end value, and generates a signal that travels linearly from start to end over a duration given in seconds. Like almost all UGens, Line also takes an optional mul and add, and then there's an argument we haven't seen yet, called doneAction.

doneActions are found with UGens that are inherently finite. For instance, an oscillator has no inherent end point, it simply generates a recurring wave shape until we tell it to stop. On the other hand, a line and other envelopes have a definitive end point. Therefore, when a finite UGen is part of an active Synth, SuperCollider wants to know what kind of action to take once the UGen has finished. doneAction allows the user to specify this action by supplying an integer.

In this help file, there's a link to a reference file called UGen done-actions. You can also find a link to this reference file at the bottom of the UGen category in the document browser. Here we can see the available doneActions and the integers associated with them. To be perfectly honest, although there are 15 options, the only doneActions I've ever used are 0 and 2, which are "do nothing" and "free the enclosing synth".

Let's return to our Line example and see how doneAction works. But first, to make these concepts more clear, let's bring up a visualization of the audio server, which is actually pretty useful in many contexts. We can do this by evaluating

Server.local

which, remember, is also stored in the global variable s

s.plotTree;

In the following example, we're controlling the amplitude of a pulse wave using a control-rate line that goes from 1 to 0 over 1 second. We haven't specified a value for doneAction, so the default value 0 is used. This means SuperCollider will take no action when the line is complete.

(
x = {
	var sig, env;
	env = Line.kr(1, 0, 1);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play
)

A Synth appears on the visual server window when we run this code. After 1 second, the line is complete, and because we've chosen doneAction:0, no further action is taken by scsynth. This means that even though we don't hear anything, the Synth is still running, as we can see on the visual representation, and it is outputting zeros at the audio rate, which means CPU cycles are being used. In addition to the audio server visualization, we can also see a "1s" on the status bar, which means there is one synth currently active.

The only way to free this Synth is to do it manually with

x.free;

or command period.

Suppose we evaluate the code above several times in a row:

(
x = {
	var sig, env;
	env = Line.kr(1, 0, 1);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play
)

Not only do these Synths pile up on the server, but we are overwriting the global variable x with each evaluation. This means that x.free will only free the most recently created synth:

x.free;

If we try x.free again, SuperCollider complains that the Synth we're trying to free doesn't exist anymore:

So now, the only option is to free everything from the server using either

s.freeAll;

or command period.

Let's do the same thing, only this time, we'll specify doneAction:2, which means SuperCollider will automatically free the enclosing Synth when the UGen is finished. Now we can run this code as much as we like, and with each Synth that's created, the server will take care of freeing it once the Line is complete.

(
x = {
	var sig, env;
	env = Line.kr(1, 0, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play
)

In fact, we don't even really need to give this Synth a name anymore. Previously, we needed to name our Synth so that we could free it later, but now SuperCollider is now handling that for us.

(
{
	var sig, env;
	env = Line.kr(1, 0, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play
)

Let's move on to XLine, which is an exponential version of Line and works in very much the same way. However, it's very important to remember that it's mathematically impossible to interpolate exponentially when including or crossing zero in the output range. So even though a Synth appears on the server when using an XLine from 1 to 0, we don't hear the expected result.

(
{
	var sig, env;
	env = XLine.kr(1, 0, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play
)

Instead, we need to constrain XLine's start and end points to either the positive or negative domain.

(
{
	var sig, env;
	env = XLine.kr(1, 0.01, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play
)

Notice that XLine sounds a little more natural than Line. This is because we perceive amplitude exponentially. We hear an amplitude of 0.5 as half as loud as 1, we hear 0.25 as half as loud as 0.5, and so on. So the exponential line makes for a nicer-sounding fade. If we were using decibels, on the other hand, we'd probably want to use Line, since the decibel is a linear measure of loudness. 0dB is twice as loud as -6dB, which is twice as loud as -12dB, and so on. We can convert from decibels to amplitude using dbamp. Here the line dips from normalized output to -40dB

(
{
	var sig, env;
	env = Line.kr(0, -40, 1, doneAction:2);
	sig = Pulse.ar(ExpRand(50,300)) * env.dbamp;
}.play
)

And for those who are curious, we can convert back to decibels from amplitude using ampdb.

0.5.ampdb;
0.25.ampdb;
0.125.ampdb;

Just to demonstrate that Line and XLine aren't restricted to amplitude control, let's use another XLine to control the frequency of the pulse wave. Again, XLine is a sensible choice because like amplitude, we also perceive frequency exponentially. 200Hz is an octave above 100Hz, 400 is an octave about 200, and so on. In this case, both our XLines have the same duration, so it doesn't really matter which one has doneAction:2, as long as one of them has it.

(
{
	var sig, env, freq;
	env = XLine.kr(1, 0.01, 1, doneAction:2);
	freq = XLine.kr(880, 110, 1, doneAction:2);
	sig = Pulse.ar(freq) * env;
}.play
)

Suppose our XLines had different durations and both had doneAction:2. In this case, whichever finishes first will free the Synth:

(
{
	var sig, env, freq;
	env = XLine.kr(1, 0.01, 1, doneAction:2);
	freq = XLine.kr(880, 110, 5, doneAction:2);
	sig = Pulse.ar(freq) * env;
}.play
)

In this case, we hear that the 5 second XLine doesn't have time to get all the way down to 110Hz, because the one-second XLine frees the Synth after it finishes. If the roles were reversed,

(
{
	var sig, env, freq;
	env = XLine.kr(1, 0.01, 5, doneAction:2);
	freq = XLine.kr(880, 110, 1, doneAction:2);
	sig = Pulse.ar(freq) * env;
}.play
)

Then the sound stops abruptly before it has time to fade out all the way to 0.01. One way to fix this is to change the doneAction on the shorter XLine to zero

(
{
	var sig, env, freq;
	env = XLine.kr(1, 0.01, 5, doneAction:2);
	freq = XLine.kr(880, 110, 1, doneAction:0);
	sig = Pulse.ar(freq) * env;
}.play
)

Or remove the doneAction entirely, which has the same effect since the default value is zero.

But now there's a different sort of problem. After 1 second, the amplitude envelope is still in progress, and the shorter XLine gets down to 110Hz after only 1 second and sits there for the remaining 4 seconds, and this may not be the sound you want. So the real solution is to conceive of all your envelope UGens together, as one sound-producing unit, and make sure that their durations are harmonious with one another. In other words, if you want a ten second sound, don't put doneAction:2 on a one second UGen.

Let's move on to a more sophisticated envelope generator, called EnvGen. EnvGen makes use of a class of objects called Env. Env is a specification for a breakpoint envelope shape, and has functionality in both the language and on the server. Also, unlike Line and XLine, EnvGen has a gate argument, which means EnvGen can be sustained indefinitely and can also be re-triggered.

EnvGen's first argument expects an instance of Env, so let's take a look at that class first. The most generalized and all-purpose method for Env is ".new". In the language, an Env can be visualized using the plot method. If we don't provide any arguments to Env.new, SuperCollider uses the defaults, which results in a simple triangle envelope:

Env.new.plot;

The first three arguments for Env.new, levels, times, and curve, are probably the most significant. The first argument, levels, should be an Array of numbers representing ordered values that EnvGen will output. The default value is the Array [0, 1, 0], which means the envelope signal will start at zero, rise to a value of 1, and return to zero. The second argument is an array of times. The size of this array is almost always one item smaller than the levels array, because the number of connecting segments is one fewer than the number of level points. In other words, if you have three level points, there are two connecting segments. The default value is the array [1, 1], which means the EnvGen will take 1 second to travel from 0 to 1, and another second to travel from 1 back to zero. The default value for curve is the symbol 'lin', which means the EnvGen will linearly interpolate between level points. If you scroll down, you can see the other options for curve. But for now, let's hear the default Env.new in action:

(
{
	var sig, env;
	env = EnvGen.kr(Env.new, doneAction:2);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play
)

Triangle envelopes are all well and good, but let's provide our own arguments for Env.new. We'll start by changing the levels array. The envelope will start at zero, rise to 1, fall to 0.2, and then fall all the way back to zero from 0.2. Since there are now four level points, I'll need three durations in the second array. I'll use 0.5, 1, and 2 seconds. I'll leave the curve argument alone for now and plot the Env, so that we can see that we have four level values, with linear interpolation, with durations equal to 0.5, 1, and 2.

Env.new([0,1,0.1,0],[0.5,1,2]).plot;

Suppose we want exponential interpolation. Changing \lin to \exp in this example won't work, as I mentioned earlier, since you can't interpolate exponentially when zero is part of the output range. So to use \exp, we'd have to change our zero levels to a very small positive number.

Env.new([0,1,0.1,0],[0.5,1,2], \exp).plot;

Env.new([0.01,1,0.1,0.01],[0.5,1,2], \exp).plot;

But a more flexible option is to use a third array of numbers to specify segment curvatures. Positive values make the segment change slowly at first, then quickly, while negative values make the segment change quickly at first, then level off. The size of this array should be equal to the size of the second array, since we need one curvature value for each breakpoint segment.

In this example

Env.new([0,1,0.1,0], [0.5,1,2], [3,-3,0]).plot;

the first curvature value is positive, so the first segment changes slowly, then quickly. The second segment has a negative curvature, so it changes quickly, then levels off.

The farther away from zero the curvature values get, the more extreme the curvature will be.

Env.new([0,1,0.1,0], [0.5,1,2], [10,-10,0]).plot;

If we reverse the first two curvature values, we see that now the first segment changes quickly at first, then levels off, while the second segment changes slowly, then drops more quickly.

Env.new([0,1,0.1,0], [0.5,1,2], [-3,3,0]).plot;

We can even replace individual numbers with valid symbols, like this:

Env.new([0,1,0.1,0], [0.5,1,2], [\sine,\sine,0]).plot;

Let's hear one of our custom envelopes in action:

(
{
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,0.1,0], [0.5,1,2], [3,-3,0]), doneAction:2);
	sig = Pulse.ar(ExpRand(50,300)) * env;
}.play
)

I'll now move on to EnvGen's second argument, "gate." In the case of fixed-length envelopes, such as the one we've been dealing with, gate can be used as a trigger, which will reset the envelope. To re-trigger the envelope, gate must change from a non-positive value to a positive value. Generally it's a good idea to just use zero and one.

(
x = {
	arg gate=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,0.1,0], [0.5,1,2], [3,-3,0]), gate);
	sig = Pulse.ar(LFPulse.kr(8).range(600,900)) * env;
}.play
)

Notice, in the EnvGen help file, that gate's default argument is 1, but I'm overwriting it with a value of zero. So the Synth has been created, but the envelope hasn't been triggered yet. All we need to do is set gate equal to 1:

x.set(\gate, 1);

A trigger occurs when the value changes from non-positive to positive. Therefore, evaluating this line again won't do anything, since gate has already been set to one. So, one option is to set gate back to zero, then set it to 1 again to retrigger.

x.set(\gate, 0);
x.set(\gate, 1);

x.free;

But it's kind of stupid to do this manually, which is why there is a special trigger argument to take care of this kind of thing. To create a trigger argument, all you have to do is precede a normal argument with t-underscore:

(
x = {
	arg t_gate=0;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,0.1,0], [0.5,1,2], [3,-3,0]), t_gate);
	sig = Pulse.ar(LFPulse.kr(8).range(600,900)) * env;
}.play
)

t-underscore arguments, according to the SynthDef help file, "will be made as a TrigControl. Setting the argument will create a control-rate impulse at the set value." This means that if you set t_gate equal to 1, it will automatically return to zero in the next control cycle, or approximately 64 samples later. This means we can re-trigger the envelope in a more intuitive way, like this:

x.set(\t_gate, 1)

x.free;

Maybe we want our Synth to trigger its envelope as soon as we create it. In this case, it makes more sense to set gate's default argument to 1 instead of zero.

(
x = {
	arg t_gate=1;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,0.1,0], [0.5,1,2], [3,-3,0]), t_gate);
	sig = Pulse.ar(LFPulse.kr(8).range(600,900)) * env;
}.play
)

and of course the envelope is still re-triggerable.

x.set(\t_gate, 1);

x.free;

It's important to use the correct doneAction when dealing with a re-triggerable envelope. In this case, if we use doneAction:2, then the envelope will be retriggerable so long as it does not reach the end. If the envelope is allowed to finish, then the synth will free itself and will no longer be accessible, as we can see from the message in the post window. When using doneAction:0, once the envelope finishes, it will output its last value until it is retriggered, and the Synth will remain on the server untill we free it.

(
x = {
	arg t_gate=1;
	var sig, env;
	env = EnvGen.kr(Env.new([0,1,0.1,0], [0.5,1,2], [3,-3,0]), t_gate, doneAction:2);
	sig = Pulse.ar(LFPulse.kr(8).range(600,900)) * env;
}.play
)

x.set(\t_gate, 1);

If you want a fixed-length envelope to be re-triggerable, it's best to use doneAction:0 and to re-trigger using a t-underscore argument. If you want a one-shot sound with a fixed-length envelope, it's better to use doneAction:2 and to create multiple synths. It all depends on the nature of the sound you're trying to make.

The last thing I'll discuss in this tutorial in the adsr envelope. We've looked at Env.new, but there's also Env.adsr. adsr stands for attack-decay-sustain-release. The fundamental difference between adsr and the previous examples is that adsr has a sustain portion, which means it can be sustained indefinitely, so long as the gate argument remains positive.

adsr takes 7 arguments: an attack time, a decay time, a sustain level, a release time, a peak level, a curvature, and a bias, and these are all just numbers, as opposed to Env.new which expects arrays of numbers. Here I'll just use the default values, but if you've been following this series so far, you should have no problem putting in your own values for adsr.

(
x = {
	arg gate=0;
	var sig, env;
	env = EnvGen.kr(Env.adsr, gate);
	sig = VarSaw.ar(SinOsc.kr(16).range(500,1000)) * env;
}.play
)

gate is zero by default, so all we have to do is open the gate to trigger the adsr envelope

x.set(\gate, 1);

there's a quick attack to an amplitude of 1, and a 0.3 second decay to a sustain amplitude of 0.5. The sound will sit at this level until the gate is set to zero, which will trigger a 1 second release.

x.set(\gate, 0);

Because there's no doneAction:2, the Synth is still hanging around, so it can be retriggered.

x.free;

Notice that it makes less sense to use a t-underscore argument for a gate when dealing with a sustainable envelope. If we were to use a trigger argument, then as soon as the envelope is triggered, t_gate will almost immediately return to zero, which will trigger the release phase of the adsr envelope.

(
x = {
	arg t_gate=0;
	var sig, env;
	env = EnvGen.kr(Env.adsr, t_gate);
	sig = VarSaw.ar(SinOsc.kr(16).range(500,1000)) * env;
}.play
)

x.set(\t_gate, 1)

x.free;

So with t_gate and an adsr envelope, there's actually no way to sustain the sound. Therefore it's better to use normal gate arguments for sustaining envelopes.

And of course, if we use doneAction:2, then the Synth will be removed after the envelope finishes.

(
x = {
	arg gate=0;
	var sig, env;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = VarSaw.ar(SinOsc.ar(20).range(500,1000)) * env;
}.play
)

x.set(\gate, 1);
x.set(\gate, 0);

Last, here's an example of using a second adsr envelope to control the frequency modulation of the oscillator sound source. I'll make use of EnvGen's 3rd and 4th arguments, levelScale and levelBias, which are almost exactly like mul and add. I'll increase the attack time of the frequency control so that the effect is more audible. Also, since these two envelopes have the same gate argument and the same release time, they will end simultaneously, so it doesn't matter which envelope has the doneAction:2

(
x = {
	arg gate=0;
	var sig, env, freq;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	freq = EnvGen.kr(Env.adsr(1), gate, 200, 0.1);
	sig = VarSaw.ar(SinOsc.ar(freq).range(300,500)) * env;
}.play
)

x.set(\gate, 1);
x.set(\gate, 0);

In the Env help file, you can find many other class methods in addition to .new and .adsr. For fixed-duration envelopes, there's a triangle shape, a sinusoid shape, a percussive shape, and others. For sustained envelopes, there's also dadsr, which has an initial delay time, and asr, which does not have a decay segment. EnvGen, especially considering its combination with Env, is a pretty deep UGen with a lot of potential that I haven't discussed in this video. But hopefully this material is enough to clarify the basic concepts.

That's it for tutorial number 4. In the next video, I'll talk about multi-channel expansion, which is an incredibly powerful and convenient shortcut for creating rich and complex sounds. If you've been enjoying this series so far, please consider giving a thumbs up and subscribing to my channel. Thanks for watching.

