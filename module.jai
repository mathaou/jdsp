#scope_file

ntryh :: int.[4, 2, 3, 5];

__decompose :: (n: int, ifac: []int, ntryh: []int) -> int {
    nl := n;
    ntry, nq, nr, i, j, nf: int;

    init := true;

    while outer := true {
        if init {
            if j < 4 {
                ntry = ntryh[j];
            } else {
                ntry += 2;
            }

            j += 1;
            init = false;
        }

        while inner := true {
            nq = nl / ntry;
            nr = nl - ntry * nq;

            if nr != 0 {
                init = true;
                break inner;
            };

            nf += 1;
            ifac[nf + 1] = ntry;
            nl = nq;

            if ntry == 2 && nf != 1 {
                for i: 2..nf {
                    ib := nf - i + 2;
                    ifac[ib + 1] = ifac[ib];
                }

                ifac[2] = 2;
            }

            if nl != 1 {
                continue inner;
            }

            break inner;
        }

        if nl == 1 {
            break outer;
        } else {
            init = true;
            continue;
        }
    }

    ifac[0] = n;
    ifac[1] = nf;

    return nf;
}

rffti1 :: (n: int, wa: []float32, ifac: []int) {
    i, j, k1, l1, l2: int;
    ld, ii, nf, ip, is: int;
    ido, ipm, nfm1: int;
    arg, argh, argld, fi: float32;

    nf = __decompose(n, ifac, ntryh);

    argh = (2.0*__M_PI) / cast(float32) n;
    is = 0;
    nfm1 = nf - 1;
    l1 = 1;

    if nfm1 == 0 {
        return;
    }

    for k1: 1..nfm1 {
        ip = ifac[k1 + 1];
        ld = 0;
        l2 = l1 * ip;
        ido = n / l2;
        ipm = ip - 1;

        for j: 1..ipm {
            ld += l1;
            i = is;
            argld = cast(float32) ld * argh;
            fi = 0.0;

            ii := 3;
            while ii <= ido {
                defer ii += 2;
                i += 2;
                fi += 1.;
                arg = fi * argld;
                wa[i - 2] = cosf(arg);
                wa[i - 1] = sinf(arg);
            }

            is += ido;
        }

        l1 = l2;
    }
}

__jfft_real_init :: (signal_length: int, wsave: []float, ifac: []int) {
    rffti1(signal_length,
        array_view(wsave, signal_length), ifac);
}

#import "Basic";

#scope_export
#load "common.jai";

jfft_create_transformer :: (signal_length: int, allocator: Allocator = temp) -> *jfft_transformer #must {
    // allocate all our memory
    jfft := New(jfft_transformer,, allocator=allocator);
    jfft.wsave = NewArray(2 * signal_length + 15 + 1, float32,, allocator=allocator);
    jfft.ifac = NewArray(FFT_IFAC, int,, allocator=allocator);

    // keep track of this for cleanup if used
    jfft.allocator = allocator;

    jfft.n = signal_length;

    if signal_length > 1 {
        __jfft_real_init(jfft.n, jfft.wsave, jfft.ifac);
    }

    return jfft;
}

jfft_destroy_transformer :: (jfft: *jfft_transformer) {
    free(*jfft.wsave,, jfft.allocator);
    free(*jfft.ifac,, jfft.allocator);
    free(jfft,, jfft.allocator);
}

#load "windowing.jai";
#if 0 {
    // WIP filters aren't quite ready
    #load "filter.jai";
}
#load "fft_forward.jai";
#load "fft_backward.jai";
