#scope_file

ntryh :: int.[4, 2, 3, 5];

// the C -> Fortran pipeline had GOTO up the wazoo so left labels as waypoints
__real_fft_init :: (n: int, wa: []float32, ifac: []int) {
    ntry := 0;
    j := -1;
    nf := 0;
    nl := n;

    labels :: enum {
        L101;
        L104;
        L107;
    }

    target := labels.L101;

    while outer := true {
        if target == {
        case labels.L101;
            j += 1;
            ifx j < 4 then ntry = ntryh[j] else ntry += 2;
            #through;
        case labels.L104;
            nq := nl / ntry;
            nr := nl - ntry * nq;
            if nr != 0 {
                __set_target_and_loop(labels.L101);
            }

            nf += 1;
            ifac[nf + 1] = ntry;
            nl = nq;

            if ntry != 2 || nf == 1 {
                __set_target_and_loop(labels.L107);
            }

            for 1..nf-1 {
                ib := nf - it + 1;
                ifac[ib + 1] = ifac[ib];
            }

            ifac[2] = 2;

            #through;
        case labels.L107;
            if nl != 1 {
                __set_target_and_loop(labels.L104);
            }

            ifac[0] = n;
            ifac[1] = nf;

            argh := TWO_PI / n;
            is := 0;
            nfm1 := nf - 1;
            l1 := 1;

            if nfm1 == 0 return;

            for x: 0..nfm1-1 {
                ip := ifac[x + 2];
                ld := 0;
                l2 := l1 * ip;
                ido := n / l2;
                ipm := ip - 1;

                for 0..ipm-1 {
                    ld += l1;
                    i := is;
                    argld := ld * argh;
                    fi := 0.0;

                    ii := 2;
                    while ii < ido {
                        defer ii += 2;
                        fi += 1.0;
                        arg := fi * argld;
                        wa[i] = cos(arg);
                        i += 1;
                        wa[i] = sin(arg);
                        i += 1;
                    }

                    is += ido;
                }


                l1 = l2;
            }

            return;
        }
    }
}

__jfft_real_init :: (signal_length: int, wsave: []float, ifac: []int) {
    __real_fft_init(signal_length,
        array_view(wsave, signal_length), ifac);
}

#scope_module

#load "common.jai";

/*
based off of fftpack - a C port of Fortran libraries
https://www.netlib.org/fftpack/fft.c
*/

jfft_create_transformer :: (signal_length: int, scale_output: bool = false, allocator: Allocator = temp) -> *jfft_transformer #must {
    // allocate all our memory
    jfft := New(jfft_transformer, allocator=allocator);
    jfft.wsave = NewArray(2 * signal_length + 15 + 1, float32, allocator=allocator);
    jfft.ifac = NewArray(FFT_IFAC, int, allocator=allocator);

    // keep track of this for cleanup if used
    jfft.allocator = allocator;

    jfft.n = signal_length;
    jfft.n_scale = 1.0 / jfft.n;
    jfft.scale_output = scale_output;

    __jfft_real_init(jfft.n, jfft.wsave, jfft.ifac);

    return jfft;
}

jfft_destroy_transformer :: (jfft: *jfft_transformer) {
    free(*jfft.wsave, jfft.allocator);
    free(*jfft.ifac, jfft.allocator);
    free(jfft, jfft.allocator);
}

#load "windowing.jai";
#load "fft_forward.jai";
#load "fft_backward.jai";