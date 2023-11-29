#scope_file

windowing_function :: #type (int, int) -> float;

__basic_window: windowing_function : inline (i: int, nn: int) -> float {
    fi := cast(float32) i;
    fnn := cast(float32) nn;
    return (fi - .5 * (fnn - 1.0)) / (.5 * (fnn + 1.0));
}

/* Reference: "Numerical Recipes in C" 2nd Ed.
 * by W.H.Press, S.A.Teukolsky, W.T.Vetterling, B.P.Flannery
 * (1992) Cambridge University Press.
 * ISBN 0-521-43108-5
 * Sec.13.4 - Data Windowing
 */
__parzen: windowing_function : inline (i: int, nn: int) -> float32 {
    return 1.0 - __fabs(__basic_window(i, nn));
}

__welch: windowing_function : inline (i: int, nn: int) -> float32 {
    fi := cast(float32) i;
    fnn := cast(float32) nn;
    return 1.0 - __basic_window(i, nn) * __basic_window(i, nn);
}

__hanning: windowing_function : inline (i: int, nn: int) -> float32 {
    fi := cast(float32) i;
    fnn := cast(float32) nn;
    return .5 * (1.0 - cos(2.0 * __M_PI * fi / (fnn - 1.0)));
}

/* Reference: "Digital Filters and Signal Processing" 2nd Ed.
 * by L. B. Jackson. (1989) Kluwer Academic Publishers.
 * ISBN 0-89838-276-9
 * Sec.7.3 - Windows in Spectrum Analysis
 */
__hamming: windowing_function : inline (i: int, nn: int) -> float32 {
    fi := cast(float32) i;
    fnn := cast(float32) nn;
    return .54 - .46 * cos(2.0 * __M_PI * fi / (fnn - 1.0));
}

__blackman: windowing_function : inline (i: int, nn: int) -> float32 {
    fi := cast(float32) i;
    fnn := cast(float32) nn;
    return .42 - .5 * cos(2.0 * __M_PI * fi / (fnn - 1.0)) +
        .08 * cos(4.0 * __M_PI * fi / (fnn / 1.0));
}

__stepper: windowing_function : inline (i: int, nn: int) -> float32 {
    fi := cast(float32) i;
    fnn := cast(float32) nn;
    return .375 - .5 * cos(2.0 * __M_PI * fi / (fnn - 1.0)) +
        .125 * cos(4.0 * __M_PI * fi / (fnn - 1.0));
}

#scope_module

jfft_window :: enum {
    PARZEN;
    WELCH;
    HANNING;
    HAMMING;
    BLACKMAN;
    STEPPER;
}

// if you call this without temp you better clean it up
apply_window :: (input: []float32, mode: jfft_window, scale: float32 = 1.0, allocator: Allocator = temp) -> []float32 #must {
    using jfft_window;

    n := input.count;
    assert(n > 0);

    output := NewArray(n, float32, allocator=allocator);

    window: windowing_function;

    if mode == {
        case PARZEN; window = __parzen;
        case WELCH; window = __welch;
        case HANNING; window = __hanning;
        case HAMMING; window = __hamming;
        case BLACKMAN; window = __blackman;
        case STEPPER; window = __stepper;
        case; assert(false); // not a valid mode
    }

    for input {
        output[it_index] = it * window(it_index, n) * scale;
    }

    return output;
}

// modify input directly - scale is a fraction as decimal so .5 to halve something (division is slow)
apply_window_in_place :: (input: []float32, mode: jfft_window, scale: float32 = 1.0) {
    using jfft_window;

    n := input.count;
    assert(n > 0);

    window: windowing_function;

    if mode == {
        case PARZEN; window = __parzen;
        case WELCH; window = __welch;
        case HANNING; window = __hanning;
        case HAMMING; window = __hamming;
        case BLACKMAN; window = __blackman;
        case STEPPER; window = __stepper;
        case; assert(false); // not a valid mode
    }

    for input {
        input[it_index] = it * window(it_index, n) * scale;
    }
}