#scope_module

#import "Math";

__M_PI : float32 = 3.1415927;

libm :: #system_library "libm";
log10f :: (arg: float32) -> float32 #foreign libm;
log2 :: (arg: float32) -> float32 #foreign libm;
sqrtf :: (arg: float32) -> float32 #foreign libm;
cosf :: (arg: float32) -> float32 #foreign libm;
sinf :: (arg: float32) -> float32 #foreign libm;

__fabs :: (f: float32) -> float32 {
    if f < 0 return f * -1;
    return f;
}

jfft_transformer :: struct {
    n: int;
    n_scale: float32; // for faster math
    wsave: []float;
    ifac: []int;
    scale_output: bool;
    allocator: Allocator;
}

// this just goes up to u32 max - if you exceed that then you must not be doing anything real-time with fft
// in which case you should know that FFT without a power of two is horribly slow
__is_power_of_two :: (x: $T) -> bool {
    return (x == 1 || x == 2 || x == 4 || x == 8 || x == 16 || x == 32 ||
		x == 64 || x == 128 || x == 256 || x == 512 || x == 1024 ||
		x == 2048 || x == 4096 || x == 8192 || x == 16384 || x == 32768 ||
		x == 65536 || x == 131072 || x == 262144 || x == 524288 ||
		x == 1048576 || x == 2097152 || x == 4194304 || x == 8388608 ||
		x == 16777216 || x == 33554432 || x == 67108864 || x == 134217728 ||
		x == 268435456 || x == 536870912 || x == 1073741824 ||
		x == 2147483648);
}

__previous_power_of_two :: (x : $T) -> T {
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >> 16);
    return x - (x >> 1);
}

__next_power_of_two :: (x: $T) -> T {
    i := 1;
    x -= 1;

    while i < size_of(T) * 8 {
        x |= x >> i;
        i *= 2;
    }

    x += 1;

    return x;
}

FFT_IFAC :: 15;
TWO_PI : float32 : #run __M_PI * 2;
TAUR: float32 : -.5;
TAUI : float32 : xx .86602540378443864676372317075293618;
sqrt2 : float32 : xx SQRT2;
HALF_SQRT_TWO : float32 : #run sqrt2 * .5;

// for forward/backward goto-style if-case
__set_target_and_loop :: (t: $T) #expand {
    `target = t;
    #insert "continue;";
}

// each index of the output array corresponds to the frequency bracket. Sample rate needed for helpful info.
// frequency := it_index / 2 * sample_rate / array_length;
jfft_magnitude :: (input: []float32, allocator: Allocator = temp) -> []float32 #must {
    n := input.count;
    i := 0;

    output := NewArray(n / 2, float32, allocator=allocator);

    while i < n {
        defer i += 2;
        cosine_component := input[i];
        sine_component := input[i + 1];
        magnitude := sqrtf((cosine_component * cosine_component) + (sine_component * sine_component));
        output[i / 2] = magnitude;
    }

    return output;
}

jfft_magnitude_transform :: (input: []float32) {
    n := input.count;
    i := 0;

    while i < n {
        defer i += 2;
        cosine_component := input[i];
        sine_component := input[i + 1];
        magnitude := sqrtf((cosine_component * cosine_component) + (sine_component * sine_component));
        input[i / 2] = magnitude;
    }
}

jfft_magnitude_db :: (input: []float32, allocator: Allocator = temp) -> []float32 #must {
    n := input.count;
    i := 0;

    output := NewArray(n / 2, float32, allocator=allocator);

    while i < n {
        defer i += 2;
        cosine_component := input[i];
        sine_component := input[i + 1];
        dB := 10 * log10f((cosine_component * cosine_component) + (sine_component * sine_component));
        output[i / 2] = dB;
    }

    return output;
}

jfft_magnitude_db_transform :: (input: []float32) {
    n := input.count;
    i := 0;

    while i < n {
        defer i += 2;
        cosine_component := input[i];
        sine_component := input[i + 1];
        dB := 10 * log10f((cosine_component * cosine_component) + (sine_component * sine_component));
        input[i / 2] = dB;
    }
}