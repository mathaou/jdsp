__dradfg :: (ido: int, ip: int, l1: int, idl1: int, cc: []float32, c1: []float32, c2: []float32, ch: []float32, ch2: []float32, wa: []float32) {
    t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10: int;
    idij, ipph, l, ic, is, nbd, idp2, ipp2: int;
    dc2, ai1, ai2, ar1, ar2, ds2, dcp, arg, dsp, ar1h, ar2h: float32;

    arg = TWO_PI / (cast(float32) ip);
    dcp = cos(arg);
    dsp = sin(arg);
    ipph = (ip + 1) >> 1;
    ipp2 = ip;
    idp2 = ido;
    nbd = (ido - 1) >> 1;
    t0 = l1 * ido;
    t10 = ip * ido;

    if ido != 1 {
        for 0..idl1-1 ch2[it] = c2[it];

        t1 = 0;
        for 1..ip-1 {
            t1 += t0;
            t2 = t1;
            for 0..l1-1 {
                ch[t2] = c1[t2];
                t2 += ido;
            }
        }

        is = -ido;
        t1 = 0;
        if nbd > l1 {
            for 1..ip-1 {
                t1 += t0;
                is += ido;
                t2 = -ido + t1;
                for 0..l1-1 {
                    idij = is - 1;
                    t2 += ido;
                    t3 = t2;

                    i := 2;
                    while i < ido {
                        defer i += 2;
                        idij += 2;
                        t3 += 2;
                        ch[t3 - 1] = wa[idij - 1] * c1[t3 - 1] + wa[idij] * c1[t3];
                        ch[t3] = wa[idij - 1] * c1[t3] - wa[idij] * c1[t3 - 1];
                    }
                }
            }
        } else {
            for 1..ip-1 {
                is += ido;
                idij = is - 1;
                t1 += t0;
                t2 = t1;
                i := 2;
                while i < ido {
                    defer i += 2;
                    idij += 2;
                    t2 += 2;
                    t3 = t2;
                    for 0..l1-1 {
                        ch[t3 - 1] = wa[idij - 1] * c1[t3 - 1] + wa[idij] * c1[t3];
                        ch[t3] = wa[idij - 1] * c1[t3] - wa[idij] * c1[t3 - 1];
                        t3 += ido;
                    }
                }
            }
        }

        t1 = 0;
        t2 = ipp2 * t0;
        if nbd < l1 {
        for 1..ipph-1 {
            t1 += t0;
            t2 -= t0;
            t3 = t1;
            t4 = t2;
            i := 2;
            while i < ido {
                defer i += 2;
                t3 += 2;
                t4 += 2;
                t5 = t3 - ido;
                t6 = t4 - ido;
                for 0..l1-1 {
                    t5 += ido;
                    t6 += ido;
                    c1[t5 - 1] = ch[t5 - 1] + ch[t6 - 1];
                    c1[t6 - 1] = ch[t5] - ch[t6];
                    c1[t5] = ch[t5] + ch[t6];
                    c1[t6] = ch[t6 - 1] - ch[t5 - 1];
                }
            }
        }
        } else {
            for 1..ipph-1 {
                t1 += t0;
                t2 -= t0;
                t3 = t1;
                t4 = t2;
                for 0..l1-1 {
                    t5 = t3;
                    t6 = t4;
                    i := 2;
                    while i < ido {
                        defer i += 2;
                        t5 += 2;
                        t6 += 2;
                        c1[t5 - 1] = ch[t5 - 1] + ch[t6 - 1];
                        c1[t6 - 1] = ch[t5] - ch[t6];
                        c1[t5] = ch[t5] + ch[t6];
                        c1[t6] = ch[t6 - 1] - ch[t5 - 1];
                    }

                    t3 += ido;
                    t4 += ido;
                }
            }
        }
    }

    labels :: enum {
        L119;
        L132;
        L135;
        L141;
    }

    target := labels.L119;

    while outer := true {
        if target == {
        case labels.L119;
            for 0..idl1-1 c2[it] = ch2[it];

            t1 = 0;
            t2 = ipp2 * idl1;
            for 1..ipph {
                t1 += t0;
                t2 -= t0;
                t3 = t1 - ido;
                t4 = t2 - ido;
                for 0..l1-1 {
                    t3 += ido;
                    t4 += ido;
                    c1[t3] = ch[t3] + ch[t4];
                    c1[t4] = ch[t4] - ch[t3];
                }
            }

            ar1 = 1.;
            ai1 = 0.;
            t1 = 0;
            t2 = ipp2 * idl1;
            t3 = (ip - 1) * idl1;

            for 1..ipph-1 {
                t1 += idl1;
                t2 -= idl1;
                ar1h = dcp * ar1 - dsp * ai1;
                ai1 = dcp * ai1 + dsp * ar1;
                ar1 = ar1h;
                t4 = t1;
                t5 = t2;
                t6 = t3;
                t7 = idl1;

                for 0..idl1 {
                    ch2[t4] = c2[it] + ar1 * c2[t7];
                    t4 += 1;
                    t7 += 1;
                    ch2[t5] = ai1 * c2[t6];
                    t5 += 1;
                    t6 += 1;
                }

                dc2 = ar1;
                ds2 = ai1;
                ar2 = ar1;
                ai2 = ai1;

                t4 = idl1;
                t5 = (ipp2 - 1) * idl1;
                for 2..ipph-1 {
                    t4 += idl1;
                    t5 -= idl1;

                    ar2h = dc2 * ar2 - ds2 * ai2;
                    ai2 = dc2 * ai2 + ds2 * ar2;
                    ar2 = ar2h;

                    t6 = t1;
                    t7 = t2;
                    t8 = t4;
                    t9 = t5;

                    for 0..idl1-1 {
                        ch2[t6] += ar2 * c2[t8];
                        t6 += 1;
                        t8 += 1;
                        ch2[t7] += ai2 * c2[t9];
                        t7 += 1;
                        t9 ++ 1;
                    }
                }
            }

            t1 = 0;
            for 1..ipph-1 {
                t1 += idl1;
                t2 = t1;
                for 0..idl1-1 {
                    ch2[it] += c2[t2];
                    t2 += 1;
                }
            }

            if ido < l1 {
                __set_target_and_loop(labels.L132);
            }

            t1 = 0;
            t2 = 0;
            for 0..l1-1 {
                t3 = t1;
                t4 = t2;
                for 0..ido-1 {
                    cc[t4] = ch[t3];
                    t4 += 1;
                    t3 += 1;
                }

                t1 += ido;
                t2 += t10;
            }

            __set_target_and_loop(labels.L135);
        case labels.L132;
            for 0..ido-1 {
                t1 = it;
                t2 = it;
                for 0..l1-1 {
                    cc[t2] = ch[t1];
                    t1 += ido;
                    t2 += t10;
                }
            }
        case labels.L135;
            t1 = 0;
            t2 = ido << 1;
            t3 = 0;
            t4 = ipp2 * t0;
            for 1..ipph-1 {
                t1 += t2;
                t3 += t0;
                t4 -= t0;

                t5 = t1;
                t6 = t3;
                t7 = t4;

                for 0..l1-1 {
                    cc[t5 - 1] = ch[t6];
                    cc[t5] = ch[t7];
                    t5 += t10;
                    t6 += ido;
                    t7 += ido;
                }
            }

            if ido == 1 return;

            if nbd < l1 {
                __set_target_and_loop(labels.L141);
            }

            t1 = -ido;
            t3 = 0;
            t4 = 0;
            t5 = ipp2 * t0;

            for 1..ipph-1 {
                t1 += t2;
                t3 += t2;
                t4 += t0;
                t5 -= t0;
                t6 = t1;
                t7 = t3;
                t8 = t4;
                t9 = t5;
                for 0..l1-1 {
                    i := 2;
                    while i < ido {
                        defer i += 2;
                        ic = idp2 - i;
                        cc[i + t7 - 1] = ch[i + t8 - 1] + ch[i + t9 - 1];
                        cc[ic + t6 - 1] = ch[i + t8 - 1] - ch[i + t9 - 1];
                        cc[i + t7] = ch[i + t8] + ch[i + t9];
                        cc[ic + t6] = ch[i + t9] - ch[i + t8];
                    }

                    t6 += t10;
                    t7 += t10;
                    t8 += ido;
                    t9 += ido;
                }
            }

            return;
        case labels.L141;
            t1 = -ido;
            t3 = 0;
            t4 = 0;
            t5 = ipp2 * t0;

            for 1..ipph-1 {
                t1 += t2;
                t3 += t2;
                t4 += t0;
                t5 -= t0;

                i := 2;
                while i < ido {
                    t6 = idp2 + t1 - i;
                    t7 = i + t3;
                    t8 = i + t4;
                    t9 = i + t5;
                    for 0..l1-1 {
                        cc[t7 - 1] = ch[t8 - 1] + ch[t9 - 1];
                        cc[t6 - 1] = ch[t8 - 1] - ch[t9 - 1];
                        cc[t7] = ch[t8] + ch[t9];
                        cc[t6] = ch[t9] - ch[t8];
                        t6 += t10;
                        t7 += t10;
                        t8 += ido;
                        t9 += ido;
                    }
                }
            }
        }
    }
}

__dradf2 :: (ido: int, l1: int, cc: []float32, ch: []float32, wa1: []float32) {
    // twiddle factors
    t0, t1, t2, t3, t4, t5, t6: int;

    t1 = 0;
    t2 = l1 * ido;
    t0 = t2;
    t3 = ido << 1;

    for 0..l1-1 {
        ch[t1 << 1] = cc[t1] + cc[t2];
        ch[(t1 << 1) + t3 - 1] = cc[t1] - cc[t2];
        t1 += ido;
        t2 += ido;
    }

    if ido < 2 return;
    else if ido != 2 {
        t1 = 0;
        t2 = t0;

        for 0..l1-1 {
            t3 = t2;
            t4 = (t1 << 1) + (ido << 1);
            t5 = t1;
            t6 = t1 + t1;

            i := 2;
            while i < ido {
                defer i += 2;
                t3 += 2;
                t4 -= 2;
                t5 += 2;
                t6 += 2;
                tr2 := wa1[i - 2] * cc[t3 - 1] + wa1[i - 1] * cc[t3];
                ti2 := wa1[i - 2] * cc[t3] - wa1[i - 1] * cc[t3 - 1];
                ch[t6] = cc[t5] + ti2;
                ch[t4] = ti2 - cc[t5];
                ch[t6 - 1] = cc[t5 - 1] + tr2;
                ch[t4 - 1] = cc[t5 - 1] - tr2;
            }

            t1 += ido;
            t2 += ido;
        }
    }

    if ido % 2 == 1 return;

    t1 = ido;
    t2 = t1 - 1;
    t3 = t2 - 1;
    t2 += t0;

    for 0..l1-1 {
        ch[t1]     = -cc[t2];
        ch[t1 - 1] =  cc[t3];
        t1 += ido << 1;
        t2 += ido;
        t3 += ido;
    }
}

// keeps track of real, imaginary, and twiddle bits of FFT
__dradf4 :: (ido: int, l1: int, cc: []float32, ch: []float32, wa1: []float32, wa2: []float32, wa3: []float32) {
    t0, t1, t2, t3, t4, t5, t6: int;
    ci2, ci3, ci4, cr2, cr3, cr4, ti1, ti2, ti3, ti4, tr1, tr2, tr3, tr4: float32;

    t0 = l1 * ido;

    t1 = t0;
    t4 = t1 << 1;
    t2 = t1 + (t1 << 1);
    t3 = 0;

    for 0..l1-1 {
        tr1 = cc[t1] + cc[t2];
        tr2 = cc[t3] + cc[t4];
        t5 = t3 << 2;
        ch[t5] = tr1 + tr2;
        ch[(ido << 2) + t5 - 1] = tr2 - tr1;
        t5 += ido << 1;
        ch[t5 - 1] = cc[t3] - cc[t4];
        ch[t5] = cc[t2] - cc[t1];

        t1 += ido;
        t2 += ido;
        t3 += ido;
        t4 += ido;
    }

    if ido < 2 return;
    else if ido != 2 {
        t1 = 0;
        for 0..l1-1 {
            t2 = t1;
            t4 = t1 << 2;
            t6 = ido << 1;
            t5 = t6 + t4;
            i := 2;
            while i < ido {
                defer i += 2;
                t2 += 2;
                t3 = t2;
                t4 += 2;
                t5 -= 2;

                // unrolled
                t3 += t0;
                cr2 = wa1[i - 2] * cc[t3 - 1] + wa1[i - 1] * cc[t3];
                ci2 = wa1[i - 2] * cc[t3] - wa1[i - 1] * cc[t3 - 1];
                t3 += t0;
                cr3 = wa2[i - 2] * cc[t3 - 1] + wa2[i - 1] * cc[t3];
                ci3 = wa2[i - 2] * cc[t3] - wa2[i - 1] * cc[t3 - 1];
                t3 += t0;
                cr4 = wa3[i - 2] * cc[t3 - 1] + wa3[i - 1] * cc[t3];
                ci4 = wa3[i - 2] * cc[t3] - wa3[i - 1] * cc[t3 - 1];

                tr1 = cr2 + cr4;
                tr4 = cr4 - cr2;
                ti1 = ci2 + ci4;
                ti4 = ci2 - ci4;
                ti2 = cc[t2] + ci3;
                ti3 = cc[t2] - ci3;
                tr2 = cc[t2 - 1] + cr3;
                tr3 = cc[t2 - 1] - cr3;

                ch[t4 - 1] = tr1 + tr2;
                ch[t4] = ti1 + ti2;

                ch[t5 - 1] = tr3 - ti4;
                ch[t5] = tr4 - ti3;

                ch[t4 + t6 - 1] = ti4 + tr3;
                ch[t4 + t6] = tr4 + ti3;

                ch[t5 + t6 - 1] = tr2 - tr1;
                ch[t5 + t6] = ti1 - ti2;
            }

            t1 += ido;
        }

        if ido % 2 == 1 return;
    }

    t1 = t0 + ido - 1;
    t2 = t1 + (t0 << 1);
    t3 = ido << 2;
    t4 = ido;
    t5 = ido << 1;
    t6 = ido;

    for 0..l1-1 {
        ti1 = -HALF_SQRT_TWO * cc[t1] + cc[t2];
        tr1 = HALF_SQRT_TWO * cc[t1] - cc[t2];
        ch[t4 - 1] = tr1 + cc[t6 - 1];
        ch[t4 + t5 - 1] = cc[t6 - 1] - tr1;
        ch[t4] = ti1 - cc[t1 + t0];
        ch[t4 + t5] = ti1 + cc[t1 + t0];
        t1 += ido;
        t2 += ido;
        t4 += t3;
        t6 += ido;
    }
}

__drftf1 :: (n: int, c: []float32, ch: []float32, wa: []float32, ifac: []int) {
    l1, l2, na, kh, nf, ip, iw, ido, idl1, ix2, ix3: int;

    nf = ifac[1];
    na = 1;
    l2 = n;
    iw = n;

    labels :: enum {
        L102;
        L103;
        L104;
        L109;
        L110;
    }

    for 0..nf-1 {
        target := labels.L102;

        kh = nf - it;
        ip = ifac[kh + 1];
        l1 = l2 / ip;
        ido = n / l2;
        idl1 = ido * l1;
        iw -= (ip - 1) * ido;
        na = 1 - na;

        if ip == 4 {
            ix2 = iw + ido;
            ix3 = ix2 + ido;

            if na != 0 {
                __dradf4(ido, l1, ch, c,
                    array_view(wa, iw - 1),
                    array_view(wa, ix2 - 1),
                    array_view(wa, ix3 - 1)
                );
            } else {
                __dradf4(ido, l1, c, ch,
                    array_view(wa, iw - 1),
                    array_view(wa, ix2 - 1),
                    array_view(wa, ix3 - 1)
                );
            }

            target = labels.L110;
        }

        while outer := true {
            if target == {
            case labels.L102;
                if ip != 2 {
                    __set_target_and_loop(labels.L104);
                } else if na != 0 {
                    __set_target_and_loop(labels.L103);
                }

                __dradf2(ido, l1, c, ch,
                    array_view(wa, iw - 1));
                __set_target_and_loop(labels.L110);
            case labels.L103;
                __dradf2(ido, l1, ch, c,
                    array_view(wa, iw - 1));
                __set_target_and_loop(labels.L110);
            case labels.L104;
                if ido == 0 {
                    na = 1 - na;
                } else if na != 0 {
                    __set_target_and_loop(labels.L109);
                }

                __dradfg(ido, ip, l1, idl1, c, c, c, ch, ch,
                    array_view(wa, iw - 1));
                na = 1;
                __set_target_and_loop(labels.L110);
            case labels.L109;
                __dradfg(ido, ip, l1, idl1, ch, ch, ch, c, c,
                    array_view(wa, iw - 1));
                na = 0;
                #through;
            case labels.L110;
                l2 = l1;
                break outer;
            }
        }
    }

    if na == 1 return;

    for 0..n-1 {
        c[it] = ch[it];
    }
}

__jfft_real_forward :: (n: int, r: []float, wsave: []float, ifac: []int) {
    __drftf1(n, r, wsave,
        array_view(wsave, n), ifac);
}

jfft_forward :: (jfft: *jfft_transformer, input: []float32) {
    #if 1 {
        if !__is_power_of_two(input.count) {
            print("[jfft] woah nelly! FFT on non-power-of-two buffers is very slow. Next power of two would be %.\n", __next_power_of_two(input.count));
            print("!!! comment this block out in `jfft_forward` if you really want to proceed, but don't say I didn't warn you. !!!");
            assert(false);
        }
    } else {
        assert(input.count % 2 == 0);
    }

    __jfft_real_forward(jfft.n, input, jfft.wsave, jfft.ifac);
}

/*
if you won't need tight control of the internal arrays of a `jfft_transformer` this is a nice addition.
However, this does three allocations per call! If you don't want a lot of page faults then you should
make transformer yourself.
*/
jfft_forward_transform :: (input: []float32, allocator: Allocator = temp) {
    #if 1 {
        if !__is_power_of_two(input.count) {
            print("[jfft] woah nelly! FFT on non-power-of-two buffers is very slow. Next power of two would be %.\n", __next_power_of_two(input.count));
            print("!!! comment this block out in `jfft_forward_transform` if you really want to proceed, but don't say I didn't warn you. !!!");
            assert(false);
        }
    } else {
        assert(input.count % 2 == 0);
    }

    jfft := jfft_create_transformer(input.count, scale_output=scale_output, allocator=allocator);

    __jfft_real_forward(jfft.n, input, jfft.wsave, jfft.ifac);

    jfft_destroy_transformer(jfft);
}