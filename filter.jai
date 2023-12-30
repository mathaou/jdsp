// this currently is WIP

tanf :: (arg: float32) -> float32 #foreign libm;
sinhf :: (arg: float32) -> float32 #foreign libm;

filter_type :: enum {
    Butterworth;
    Chebyshev;
}

jdsp_filter :: struct {
    type: filter_type;
    n: int;
    A: []float32;
    d1: []float32;
    d2: []float32;
    w0: []float32;
    w1: []float32;
    w2: []float32;
    epsilon: float32; // for Chebyshev
}

jdsp_highpass_filter :: #type jdsp_filter;
jdsp_lowpass_filter :: #type jdsp_filter; // same fields

jdsp_bandpass_filter :: struct {
    using #as filter: jdsp_filter;
    d3: []float32;
    d4: []float32;
    w3: []float32;
    w4: []float32;
}

jdsp_bandstop_filter :: struct {
    using #as filter: jdsp_filter;
    r: float32;
    s: float32;
    d3: []float32;
    d4: []float32;
    w3: []float32;
    w4: []float32;
}

jdsp_lowpass_init :: (order: int, sample_rate: float32, half_power_frequency: float32, $type: filter_type = filter_type.Butterworth, epsilon: float = -1, allocator: Allocator = temp) -> *jdsp_lowpass_filter #must {
    using filter_type;
    filter: *jdsp_lowpass_filter = New(jdsp_lowpass_filter, allocator=allocator);
    filter.n = order/2;
    filter.A = NewArray(filter.n, float32, allocator=allocator);
    filter.d1 = NewArray(filter.n, float32, allocator=allocator);
    filter.d2 = NewArray(filter.n, float32, allocator=allocator);
    filter.w0 = NewArray(filter.n, float32, allocator=allocator);
    filter.w1 = NewArray(filter.n, float32, allocator=allocator);
    filter.w2 = NewArray(filter.n, float32, allocator=allocator);
    a := tanf(__M_PI * half_power_frequency / sample_rate);
    a2 := a * a;

    filter.type = type;

    print("creating % lowpass filter\n", type);

    #if type == Chebyshev {
        print(#string DATA
Chebyshev requires an epsilon value that ideally is computed as follows:

passband_dB := -.5; // this is complicated to explain look it up
epsilon := sqrtf(pow(10.0, passband_dB/10.0) -1);

https://en.wikipedia.org/wiki/Chebyshev_filter
        DATA);
        assert(epsilon != -1);

        u: float32 = logf(1.0 + sqrt(1.0 + epsilon * epsilon) / epsilon);
        su: float32 = sinhf(u / cast(float32) order);
        cu: float32 = coshf(u / cast(float32) order);

        b, c, s: float32;

        for i: 0..filter.n-1 {
            b = sinf(__M_PI * (2.0 * i + 1.0) / (2.0 * order)) * su;
            c = cosf(__M_PI * (2.0 * i + 1.0) / (2.0 * order)) * cu;
            c = b*b + c*c;
            s = a2 * c + 2.0 * a * b + 1.0;
            filter.A[i] = a2 / (4.0 * s);
            filter.d1[i] = 2.0 * (1 - a2 * c) / s;
            filter.d2[i] = -(a2 * c - 2.0 * a * b + 1.0) / s;
        }

        filter.epsilon = (2.0 / epsilon); // used to normalize
    } else #if type == Butterworth {
        r, s: float32;

        for i: 0..filter.n-1 {
            r = sinf(__M_PI * (2.0 * i + 1.0) / (4.0 * filter.n));
            s = a2 + 2.0 * a * r + 1.0;
            filter.A[i] = a2 / s;
            filter.d1[i] = 2.0 * (1 - a2) / s;
            filter.d2[i] = -(a2 - 2.0 * a * r + 1.0) / s;
        }
    }

    return filter;
}

jdsp_highpass_init :: (order: int, sample_rate: float32, half_power_frequency: float32, $type: filter_type = filter_type.Butterworth, epsilon: float = -1, allocator: Allocator = temp) -> *jdsp_highpass_filter #must {
    using filter_type;
    filter: *jdsp_highpass_filter = New(jdsp_highpass_filter, allocator=allocator);
    filter.n = order/2;
    filter.A = NewArray(filter.n, float32, allocator=allocator);
    filter.d1 = NewArray(filter.n, float32, allocator=allocator);
    filter.d2 = NewArray(filter.n, float32, allocator=allocator);
    filter.w0 = NewArray(filter.n, float32, allocator=allocator);
    filter.w1 = NewArray(filter.n, float32, allocator=allocator);
    filter.w2 = NewArray(filter.n, float32, allocator=allocator);
    a := tanf(__M_PI * half_power_frequency / sample_rate);
    a2 := a * a;

    filter.type = type;

    print("creating % highpass filter\n", type);

    #if type == Chebyshev {
        print(#string DATA
Chebyshev requires an epsilon value that ideally is computed as follows:

passband_dB := -.5; // this is complicated to explain look it up
epsilon := sqrtf(pow(10.0, passband_dB/10.0) -1);

https://en.wikipedia.org/wiki/Chebyshev_filter
        DATA);
        assert(epsilon != -1);

        u: float32 = logf(1.0 + sqrt(1.0 + epsilon * epsilon) / epsilon);
        su: float32 = sinhf(u / cast(float32) order);
        cu: float32 = coshf(u / cast(float32) order);

        b, c, s: float32;

        for i: 0..filter.n-1 {
            b = sinf(__M_PI * (2.0 * i + 1.0) / (2.0 * order)) * su;
            c = cosf(__M_PI * (2.0 * i + 1.0) / (2.0 * order)) * cu;
            c = b*b + c*c;
            s = a2 + 2.0 * a * b + c;
            filter.A[i] = 1.0 / (4.0 * s);
            filter.d1[i] = 2.0 * (c - a2) / s;
            filter.d2[i] = -(a2 - 2.0 * a * b + c) / s;
        }

        filter.epsilon = (2.0 / epsilon); // used to normalize
    } else #if type == Butterworth {
        r, s: float32;

        for i: 0..filter.n-1 {
            r = sinf(__M_PI * (2.0 * i + 1.0) / (4.0 * filter.n));
            s = a2 + 2.0 * a * r + 1.0;
            filter.A[i] = 1.0 / s;
            filter.d1[i] = 2.0 * (1 - a2) / s;
            filter.d2[i] = -(a2 - 2.0 * a * r + 1.0) / s;
        }
    }

    return filter;
}

jdsp_bandpass_init :: (order: int, sample_rate: float32, lower_half_power_frequency: float32, upper_half_power_frequency: float32, $type: filter_type = filter_type.Butterworth, epsilon: float = -1, allocator: Allocator = temp) -> *jdsp_bandpass_filter #must {
    using filter_type;
    filter: *jdsp_bandpass_filter = New(jdsp_bandpass_filter, allocator=allocator);
    filter.n = order/4;
    filter.A = NewArray(filter.n, float32, allocator=allocator);
    filter.d1 = NewArray(filter.n, float32, allocator=allocator);
    filter.d2 = NewArray(filter.n, float32, allocator=allocator);
    filter.d3 = NewArray(filter.n, float32, allocator=allocator);
    filter.d4 = NewArray(filter.n, float32, allocator=allocator);
    filter.w0 = NewArray(filter.n, float32, allocator=allocator);
    filter.w1 = NewArray(filter.n, float32, allocator=allocator);
    filter.w2 = NewArray(filter.n, float32, allocator=allocator);
    filter.w3 = NewArray(filter.n, float32, allocator=allocator);
    filter.w4 = NewArray(filter.n, float32, allocator=allocator);

    a := cosf(__M_PI * (lower_half_power_frequency + upper_half_power_frequency) / sample_rate) /
        cosf(__M_PI * (upper_half_power_frequency - lower_half_power_frequency) / sample_rate);
    a2 := a * a;
    b := tanf(__M_PI * (upper_half_power_frequency - lower_half_power_frequency) / sample_rate);
    b2 := b * b;

    filter.type = type;

    print("creating % bandpass filter\n", type);

    #if type == Chebyshev {
        print(#string DATA
Chebyshev requires an epsilon value that ideally is computed as follows:

passband_dB := -.5; // this is complicated to explain look it up
epsilon := sqrtf(pow(10.0, passband_dB/10.0) -1);

https://en.wikipedia.org/wiki/Chebyshev_filter
        DATA);
        assert(epsilon != -1);

        u: float32 = logf(1.0 + sqrt(1.0 + epsilon * epsilon) / epsilon);
        su: float32 = sinhf(2.0 * u / cast(float32) order);
        cu: float32 = coshf(2.0 * u / cast(float32) order);

        b, c, s, r: float32;

        for i: 0..filter.n-1 {
            r = sinf(__M_PI * (2.0 * i + 1.0) / order) * su;
            c = cosf(__M_PI * (2.0 * i + 1.0) / order) * cu;
            c = r*r + c*c;
            s = a2 + 2.0 * a * b + c;
            filter.A[i] = b2 / (4.0 * s);
            filter.d1[i] = 4.0 * a * (1.0 + b * r) / s;
            filter.d2[i] = 2.0 * (b2 * c - 2.0 * a2 - 1.0) / s;
            filter.d3[i] = 4.0 * a * (1.0 - b * r) / s;
            filter.d4[i] = -(b2 * c - 2.0 * b * r + 1.0) / s;
        }

        filter.epsilon = (2.0 / epsilon); // used to normalize
    } else #if type == Butterworth {
        r, s: float32;

        for i: 0..filter.n-1 {
            r = sinf(__M_PI * (2.0 * i + 1.0) / (4.0 * filter.n));
            s = b2 + 2.0 * b * r + 1.0;
            filter.A[i] = b2 / s;
            filter.d1[i] = 4.0 * a * (1.0 + b * r) / s;
            filter.d2[i] = 2.0 * (b2 - 2.0 * a2 - 1.0) / s;
            filter.d3[i] = 4.0 * a * (1.0 - b * r ) / s;
            filter.d4[i] = -(b2 - 2.0 * b * r + 1.0) / s;
        }
    }

    return filter;
}

jdsp_bandstop_init :: (order: int, sample_rate: float32, lower_half_power_frequency: float32, upper_half_power_frequency: float32, $type: filter_type = filter_type.Butterworth, epsilon: float = -1, allocator: Allocator = temp) -> *jdsp_bandstop_filter #must {
    using filter_type;
    filter: *jdsp_bandstop_filter = New(jdsp_bandstop_filter, allocator=allocator);
    filter.n = order/4;
    filter.A = NewArray(filter.n, float32, allocator=allocator);
    filter.d1 = NewArray(filter.n, float32, allocator=allocator);
    filter.d2 = NewArray(filter.n, float32, allocator=allocator);
    filter.d3 = NewArray(filter.n, float32, allocator=allocator);
    filter.d4 = NewArray(filter.n, float32, allocator=allocator);
    filter.w0 = NewArray(filter.n, float32, allocator=allocator);
    filter.w1 = NewArray(filter.n, float32, allocator=allocator);
    filter.w2 = NewArray(filter.n, float32, allocator=allocator);
    filter.w3 = NewArray(filter.n, float32, allocator=allocator);
    filter.w4 = NewArray(filter.n, float32, allocator=allocator);

    a := cosf(__M_PI * (lower_half_power_frequency + upper_half_power_frequency) / sample_rate) /
        cosf(__M_PI * (upper_half_power_frequency - lower_half_power_frequency) / sample_rate);
    a2 := a * a;
    b := tanf(__M_PI * (upper_half_power_frequency - lower_half_power_frequency) / sample_rate);
    b2 := b * b;

    filter.type = type;

    print("creating % bandstop filter\n", type);

    #if type == Chebyshev {
        print(#string DATA
Chebyshev requires an epsilon value that ideally is computed as follows:

passband_dB := -.5; // this is complicated to explain look it up
epsilon := sqrtf(pow(10.0, passband_dB/10.0) -1);

https://en.wikipedia.org/wiki/Chebyshev_filter
        DATA);
        assert(epsilon != -1);

        u: float32 = logf(1.0 + sqrt(1.0 + epsilon * epsilon) / epsilon);
        su: float32 = sinhf(2.0 * u / cast(float32) order);
        cu: float32 = coshf(2.0 * u / cast(float32) order);

        b, c, s, r: float32;

        for i: 0..filter.n-1 {
            r = sinf(__M_PI * (2.0 * i + 1.0) / order) * su;
            c = cosf(__M_PI * (2.0 * i + 1.0) / order) * cu;
            c = r*r + c*c;
            s = b2 + 2.0 * b * r + c;
            filter.A[i] = 1.0 / (4.0 * s);
            filter.d1[i] = 4.0 * a * (c + b * r) / s;
            filter.d2[i] = 2.0 * (b2 - 2.0 * a2 * c - c) / s;
            filter.d3[i] = 4.0 * a * (c - b * r) / s;
            filter.d4[i] = -(b2 - 2.0 * b * r + c) / s;
        }

        filter.r = 4.0 * a;
        filter.s = 4.0 * a2 + 2.0;
        filter.epsilon = (2.0 / epsilon); // used to normalize
    } else #if type == Butterworth {
        r, s: float32;

        for i: 0..filter.n-1 {
            r = sinf(__M_PI * (2.0 * i + 1.0) / (4.0 * filter.n));
            s = b2 + 2.0 * b * r + 1.0;
            filter.A[i] = 1.0 / s;
            filter.d1[i] = 4.0 * a * (1.0 + b * r) / s;
            filter.d2[i] = 2.0 * (b2 - 2.0 * a2 - 1.0) / s;
            filter.d3[i] = 4.0 * a * (1.0 - b * r ) / s;
            filter.d4[i] = -(b2 - 2.0 * b * r + 1.0) / s;
        }

        filter.r = 4.0 * a;
        filter.s = 4.0 * a2 + 2.0;
    }

    return filter;
}

jdsp_apply_filter :: (filter: *$T/jdsp_filter, x: float32) -> float32 {
    assert(filter != null);

    using filter_type;

    #if T == jdsp_lowpass_filter {
        for i: 0..filter.n-1 {
            filter.w0[i] = filter.d1[i]*filter.w1[i] + filter.d2[i]*filter.w2[i] + x;
            x = filter.A[i] * (filter.w0[i] + 2.0 * filter.w1[i] + filter.w2[i]);
            filter.w2[i] = filter.w1[i];
            filter.w1[i] = filter.w0[i];
        }
    } else #if T == jdsp_highpass_filter {
        for i: 0..filter.n-1 {
            filter.w0[i] = filter.d1[i]*filter.w1[i] + filter.d2[i]*filter.w2[i] + x;
            x = filter.A[i] * (filter.w0[i] - 2.0 * filter.w1[i] + filter.w2[i]);
            filter.w2[i] = filter.w1[i];
            filter.w1[i] = filter.w0[i];
        }
    } else #if T == jdsp_bandpass_filter {
        for i: 0..filter.n-1 {
            filter.w0[i] = filter.d1[i] * filter.w1[i] + filter.d2[i] * filter.w2[i] + filter.d3[i] * filter.w3[i] + filter.d4[i] * filter.w4[i] + x;
            x = filter.A[i] * (filter.w0[i] - 2.0 * filter.w2[i] + filter.w4[i]);
            filter.w4[i] = filter.w3[i];
            filter.w3[i] = filter.w2[i];
            filter.w2[i] = filter.w1[i];
            filter.w1[i] = filter.w0[i];
        }
    } else #if T == jdsp_bandstop_filter {
        for i: 0..filter.n-1 {
            filter.w0[i] = filter.d1[i] * filter.w1[i] + filter.d2[i] * filter.w2[i] + filter.d3[i] * filter.w3[i] + filter.d4[i] * filter.w4[i] + x;
            x = filter.A[i]*(filter.w0[i] - filter.r*filter.w1[i] + filter.s*filter.w2[i] - filter.r*filter.w3[i] + filter.w4[i]);
            filter.w4[i] = filter.w3[i];
            filter.w3[i] = filter.w2[i];
            filter.w2[i] = filter.w1[i];
            filter.w1[i] = filter.w0[i];
        }
    }

    if #complete filter.type == {
    case Butterworth;
        return x;
    case Chebyshev;
        return x * filter.epsilon;
    }
}

jdsp_apply_softmax :: (data: []float32, target: int) -> float32 {
    sum: float32;
    for data sum += it;

    return data[target] / sum;
}

jdsp_free_filter :: (filter: $T/jdsp_filter, allocator: Allocator = temp) {
    t := type_of(filter);

    free(*filter.A,, allocator);
    free(*filter.d1,, allocator);
    free(*filter.d2,, allocator);
    free(*filter.w0,, allocator);
    free(*filter.w1,, allocator);
    free(*filter.w2,, allocator);

    #if t == jdsp_bandstop || t == jdsp_bandpass {
        free(*filter.d3,, allocator);
        free(*filter.d4,, allocator);
        free(*filter.w3,, allocator);
        free(*filter.w4,, allocator);
    }

    free(filter);
}