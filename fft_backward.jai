// for radix 1-5
cc_index :: (a: int, b: int, c: int) -> int #expand {
    return (((c)*`radix + (b))*`ido + a) - `cc_offset;
}

ch_index :: (a: int, b: int, c: int) -> int #expand {
    return (((c)*`l1 + (b))*`ido + a) - `ch_offset;
}

// for the g radix option
c1_ref :: (a: int, b: int, c: int) -> int #expand {
    return ((c)*`l1 + (b))*`ido + a - `c1_offset;
}

c2_ref :: (a: int, b: int) -> int #expand {
    return (b)*`idl1 + a - `c2_offset;
}

cc_ref :: (a: int, b: int, c: int) -> int #expand {
    return ((c)*`ip + (b))*`ido + a - `cc_offset;
}

ch_ref :: (a: int, b: int, c: int) -> int #expand {
    return ((c)*`l1 + (b))*`ido + a - `ch_offset;
}

ch2_ref :: (a: int, b: int) -> int #expand{
    return (b)*`idl1 + a - `ch2_offset;
}

radbg :: (ido: int, ip: int, l1: int, idl1: int,
                  cc: []float32, c1: []float32, c2: []float32, ch: []float32, ch2: []float32, wa: []float32) {
    ch_offset, cc_offset, c1_offset, c2_offset, ch2_offset: int;
    j2, ic, jc, lc, ik, is: int;
    dc2, ai1, ai2, ar1, ar2, ds2: float32;
    nbd: int;
    dcp, arg, dsp, ar1h, ar2h: float32;
    idp2, ipp2, idij, ipph: int;

    ch_offset = 1 + ido * (1 + l1);
    c1_offset = 1 + ido * (1 + l1);
    cc_offset = 1 + ido * (1 + ip);
    ch2_offset = 1 + idl1;
    c2_offset = 1 + idl1;

    /* Function Body */
    arg = (2*__M_PI) / cast(float32) (ip);
    dcp = cosf(arg);
    dsp = sinf(arg);
    idp2 = ido + 2;
    nbd = (ido - 1) / 2;
    ipp2 = ip + 2;
    ipph = (ip + 1) / 2;

    if ido >= l1 {
        for k: 1..l1 {
            for i: 1..ido {
                ch[ch_ref(i, k, 1)] = cc[cc_ref(i, 1, k)];
            }
        }
    } else {
        for i: 1..ido {
            for k: 1..l1 {
                ch[ch_ref(i, k, 1)] = cc[cc_ref(i, 1, k)];
            }
        }
    }
    for j: 2..ipph {
        jc = ipp2 - j;
        j2 = j + j;

        for k: 1..l1 {
            ch[ch_ref(1, k, j)] = cc[cc_ref(ido, j2 - 2, k)] + cc[cc_ref(ido, j2 - 2, k)];
            ch[ch_ref(1, k, jc)] = cc[cc_ref(1, j2 - 1, k)] + cc[cc_ref(1, j2 - 1, k)];
        }
    }

    if ido != 1 {
        if nbd >= l1 {
            for j: 2..ipph {
                jc = ipp2 - j;
                for k: 1..l1 {
                    i := 3;
                    while i <= ido {
                        defer i += 2;
                        ic = idp2 - i;
                        ch[ch_ref(i - 1, k, j)] = cc[cc_ref(i - 1, (j << 1) - 1, k)] + cc[cc_ref(ic - 1, (j << 1) - 2, k)];
                        ch[ch_ref(i - 1, k, jc)] = cc[cc_ref(i - 1, (j << 1) - 1, k)] - cc[cc_ref(ic - 1, (j << 1) - 2, k)];
                        ch[ch_ref(i, k, j)] = cc[cc_ref(i, (j << 1) - 1, k)] - cc[cc_ref(ic, (j << 1) - 2, k)];
                        ch[ch_ref(i, k, jc)] = cc[cc_ref(i, (j << 1) - 1, k)] + cc[cc_ref(ic, (j << 1) - 2, k)];
                    }
                }
            }
        } else {
            for j: 2..ipph {
                jc = ipp2 - j;
                i := 3;
                while i <= ido {
                    defer i += 2;
                    ic = idp2 - i;

                    for k: 1..l1 {
                        ch[ch_ref(i - 1, k, j)] = cc[cc_ref(i - 1, (j << 1) - 1, k)] + cc[cc_ref(ic - 1, (j << 1) - 2, k)];
                        ch[ch_ref(i - 1, k, jc)] = cc[cc_ref(i - 1, (j << 1) - 1, k)] - cc[cc_ref(ic - 1, (j << 1) - 2, k)];
                        ch[ch_ref(i, k, j)] = cc[cc_ref(i, (j << 1) - 1, k)] - cc[cc_ref(ic, (j << 1) - 2, k)];
                        ch[ch_ref(i, k, jc)] = cc[cc_ref(i, (j << 1) - 1, k)] + cc[cc_ref(ic, (j << 1) - 2, k)];
                    }
                }
            }
        }
    }

    ar1 = 1.0;
    ai1 = 0.0;

    for l: 2..ipph {
        lc = ipp2 - l;
        ar1h = dcp * ar1 - dsp * ai1;
        ai1 = dcp * ai1 + dsp * ar1;
        ar1 = ar1h;

        for ik: 1..idl1 {
            c2[c2_ref(ik, l)] = ch2[ch2_ref(ik, 1)] + ar1 * ch2[ch2_ref(ik, 2)];
            c2[c2_ref(ik, lc)] = ai1 * ch2[ch2_ref(ik, ip)];
        }

        dc2 = ar1;
        ds2 = ai1;
        ar2 = ar1;
        ai2 = ai1;

        for j: 3..ipph {
            jc = ipp2 - j;
            ar2h = dc2 * ar2 - ds2 * ai2;
            ai2 = dc2 * ai2 + ds2 * ar2;
            ar2 = ar2h;
            for ik: 1..idl1 {
                c2[c2_ref(ik, l)] = c2[c2_ref(ik, l)] + ar2 * ch2[ch2_ref(ik, j)];
                c2[c2_ref(ik, lc)] = c2[c2_ref(ik, lc)] + ai2 * ch2[ch2_ref(ik, jc)];
            }
        }
    }

    for j: 2..ipph {
        for ik: 1..idl1 {
            ch2[ch2_ref(ik, 1)] = ch2[ch2_ref(ik, 1)] + ch2[ch2_ref(ik, j)];
        }
    }

    for j: 2..ipph {
        jc = ipp2 - j;
        for k: 1..l1 {
            ch[ch_ref(1, k, j)] = c1[c1_ref(1, k, j)] - c1[c1_ref(1, k, jc)];
            ch[ch_ref(1, k, jc)] = c1[c1_ref(1, k, j)] + c1[c1_ref(1, k, jc)];
        }
    }

    if (ido != 1) {
        if (nbd >= l1) {
            for j: 2..ipph {
                jc = ipp2 - j;
                for k: 1..l1 {
                    i := 3;
                    while i <= ido {
                        defer i += 2;

                        ch[ch_ref(i - 1, k, j)] = c1[c1_ref(i - 1, k, j)] - c1[c1_ref(i, k, jc)];
                        ch[ch_ref(i - 1, k, jc)] = c1[c1_ref(i - 1, k, j)] + c1[c1_ref(i, k, jc)];
                        ch[ch_ref(i, k, j)] = c1[c1_ref(i, k, j)] + c1[c1_ref(i - 1, k, jc)];
                        ch[ch_ref(i, k, jc)] = c1[c1_ref(i, k, j)] - c1[c1_ref(i - 1, k, jc)];
                    }
                }
            }
        } else {
            for j: 2..ipph {
                jc = ipp2 - j;

                i := 3;
                while i <= ido {
                    i += 2;
                    for k: 1..l1 {
                        ch[ch_ref(i - 1, k, j)] = c1[c1_ref(i - 1, k, j)] - c1[c1_ref(i, k, jc)];
                        ch[ch_ref(i - 1, k, jc)] = c1[c1_ref(i - 1, k, j)] + c1[c1_ref(i, k, jc)];
                        ch[ch_ref(i, k, j)] = c1[c1_ref(i, k, j)] + c1[c1_ref(i - 1, k, jc)];
                        ch[ch_ref(i, k, jc)] = c1[c1_ref(i, k, j)] - c1[c1_ref(i - 1, k, jc)];
                    }
                }
            }
        }
    }

    if ido == 1 return;

    for ik: 1..idl1 {
        c2[c2_ref(ik, 1)] = ch2[ch2_ref(ik, 1)];
    }

    for j: 2..ip {
        for k: 1..l1 {
            c1[c1_ref(1, k, j)] = ch[ch_ref(1, k, j)];
        }
    }

    if nbd <= l1 {
        is = -(ido);
        for j: 2..ip {
            is += ido;
            idij = is;

            i := 3;
            while i <= ido {
                defer i += 2;

                idij += 2;
                for k: 1..l1 {
                    c1[c1_ref(i - 1, k, j)] = wa[idij - 1] * ch[ch_ref(i - 1, k, j)] - wa[idij] * ch[ch_ref(i, k, j)];
                    c1[c1_ref(i, k, j)] = wa[idij - 1] * ch[ch_ref(i, k, j)] + wa[idij] * ch[ch_ref(i - 1, k, j)];
                }
            }
        }
    } else {
        is = -(ido);
        for j: 2..ip {
            is += ido;
            for k: 1..l1 {
                idij = is;

                i := 3;
                while i <= ido {
                    defer i += 2;

                    idij += 2;
                    c1[c1_ref(i - 1, k, j)] = wa[idij - 1] * ch[ch_ref(i - 1, k, j)]
                    - wa[idij] * ch[ch_ref(i, k, j)];
                    c1[c1_ref(i, k, j)] = wa[idij - 1] * ch[ch_ref(i, k, j)] + wa[idij] * ch[ch_ref(i - 1, k, j)];
                }
            }
        }
    }
}

radb5 :: (ido: int, l1: int, cc: []float32, ch: []float32, wa1: []float32, wa2: []float32, wa3: []float32, wa4: []float32) {
    tr11 : float32 = xx .309016994374947;
    ti11 : float32 = xx .951056516295154;
    tr12 : float32 = xx -.809016994374947;
    ti12 : float32 = xx .587785252292473;

    cc_offset, ch_offset, ic: int;
    ci2, ci3, ci4, ci5, di3, di4, di5, di2, cr2, cr3, cr5, cr4, ti2, ti3: float32;
    ti4, ti5, dr3, dr4, dr5, dr2, tr2, tr3, tr4, tr5: float32;
    idp2: int;

    ch_offset = 1 + ido * (1 + l1);
    cc_offset = 1 + ido * 6;
    radix := 5;

    /* Function Body */
    for k: 1..l1 {
        ti5 = cc[cc_index(1, 3, k)] + cc[cc_index(1, 3, k)];
        ti4 = cc[cc_index(1, 5, k)] + cc[cc_index(1, 5, k)];
        tr2 = cc[cc_index(ido, 2, k)] + cc[cc_index(ido, 2, k)];
        tr3 = cc[cc_index(ido, 4, k)] + cc[cc_index(ido, 4, k)];
        ch[ch_index(1, k, 1)] = cc[cc_index(1, 1, k)] + tr2 + tr3;
        cr2 = cc[cc_index(1, 1, k)] + tr11 * tr2 + tr12 * tr3;
        cr3 = cc[cc_index(1, 1, k)] + tr12 * tr2 + tr11 * tr3;
        ci5 = ti11 * ti5 + ti12 * ti4;
        ci4 = ti12 * ti5 - ti11 * ti4;

        ch[ch_index(1, k, 2)] = cr2 - ci5;
        ch[ch_index(1, k, 3)] = cr3 - ci4;
        ch[ch_index(1, k, 4)] = cr3 + ci4;
        ch[ch_index(1, k, 5)] = cr2 + ci5;
    }

    if ido == 1 return;

    idp2 = ido + 2;

    for k: 1..l1 {
        i := 3;
        while i <= ido {
            defer i += 2;

            ic = idp2 - i;
            ti5 = cc[cc_index(i, 3, k)] + cc[cc_index(ic, 2, k)];
            ti2 = cc[cc_index(i, 3, k)] - cc[cc_index(ic, 2, k)];
            ti4 = cc[cc_index(i, 5, k)] + cc[cc_index(ic, 4, k)];
            ti3 = cc[cc_index(i, 5, k)] - cc[cc_index(ic, 4, k)];
            tr5 = cc[cc_index(i - 1, 3, k)] - cc[cc_index(ic - 1, 2, k)];
            tr2 = cc[cc_index(i - 1, 3, k)] + cc[cc_index(ic - 1, 2, k)];
            tr4 = cc[cc_index(i - 1, 5, k)] - cc[cc_index(ic - 1, 4, k)];
            tr3 = cc[cc_index(i - 1, 5, k)] + cc[cc_index(ic - 1, 4, k)];
            ch[ch_index(i - 1, k, 1)] = cc[cc_index(i - 1, 1, k)] + tr2 + tr3;
            ch[ch_index(i, k, 1)] = cc[cc_index(i, 1, k)] + ti2 + ti3;
            cr2 = cc[cc_index(i - 1, 1, k)] + tr11 * tr2 + tr12 * tr3;
            ci2 = cc[cc_index(i, 1, k)] + tr11 * ti2 + tr12 * ti3;
            cr3 = cc[cc_index(i - 1, 1, k)] + tr12 * tr2 + tr11 * tr3;
            ci3 = cc[cc_index(i, 1, k)] + tr12 * ti2 + tr11 * ti3;
            cr5 = ti11 * tr5 + ti12 * tr4;
            ci5 = ti11 * ti5 + ti12 * ti4;
            cr4 = ti12 * tr5 - ti11 * tr4;
            ci4 = ti12 * ti5 - ti11 * ti4;
            dr3 = cr3 - ci4;
            dr4 = cr3 + ci4;
            di3 = ci3 + cr4;
            di4 = ci3 - cr4;
            dr5 = cr2 + ci5;
            dr2 = cr2 - ci5;
            di5 = ci2 - cr5;
            di2 = ci2 + cr5;

            ch[ch_index(i - 1, k, 2)] = wa1[i - 3] * dr2 - wa1[i - 2] * di2;
            ch[ch_index(i, k, 2)] = wa1[i - 3] * di2 + wa1[i - 2] * dr2;
            ch[ch_index(i - 1, k, 3)] = wa2[i - 3] * dr3 - wa2[i - 2] * di3;
            ch[ch_index(i, k, 3)] = wa2[i - 3] * di3 + wa2[i - 2] * dr3;
            ch[ch_index(i - 1, k, 4)] = wa3[i - 3] * dr4 - wa3[i - 2] * di4;
            ch[ch_index(i, k, 4)] = wa3[i - 3] * di4 + wa3[i - 2] * dr4;
            ch[ch_index(i - 1, k, 5)] = wa4[i - 3] * dr5 - wa4[i - 2] * di5;
            ch[ch_index(i, k, 5)] = wa4[i - 3] * di5 + wa4[i - 2] * dr5;
        }
    }
}

radb4 :: (ido: int, l1: int, cc: []float32, ch: []float32, wa1: []float32, wa2: []float32, wa3: []float32) {
    cc_offset, ch_offset: int;
    i, k, ic: int;
    ci2, ci3, ci4, cr2, cr3, cr4, ti1, ti2, ti3, ti4, tr1, tr2, tr3, tr4: float32;
    idp2: int;

    radix := 4;

    ch_offset = 1 + ido * (1 + l1);
    cc_offset = 1 + ido * 5;

    for k: 1..l1 {
        tr1 = cc[cc_index(1, 1, k)] - cc[cc_index(ido, 4, k)];
        tr2 = cc[cc_index(1, 1, k)] + cc[cc_index(ido, 4, k)];
        tr3 = cc[cc_index(ido, 2, k)] + cc[cc_index(ido, 2, k)];
        tr4 = cc[cc_index(1, 3, k)] + cc[cc_index(1, 3, k)];

        ch[ch_index(1, k, 1)] = tr2 + tr3;
        ch[ch_index(1, k, 2)] = tr1 - tr4;
        ch[ch_index(1, k, 3)] = tr2 - tr3;
        ch[ch_index(1, k, 4)] = tr1 + tr4;
    }

    if ido < 2 return;
    if (ido != 2) {
        idp2 = ido + 2;
        for k: 1..l1 {
            i := 3;
            while i <= ido {
                defer i += 2;
                ic = idp2 - i;
                ti1 = cc[cc_index(i, 1, k)] + cc[cc_index(ic, 4, k)];
                ti2 = cc[cc_index(i, 1, k)] - cc[cc_index(ic, 4, k)];
                ti3 = cc[cc_index(i, 3, k)] - cc[cc_index(ic, 2, k)];
                tr4 = cc[cc_index(i, 3, k)] + cc[cc_index(ic, 2, k)];
                tr1 = cc[cc_index(i - 1, 1, k)] - cc[cc_index(ic - 1, 4, k)];
                tr2 = cc[cc_index(i - 1, 1, k)] + cc[cc_index(ic - 1, 4, k)];
                ti4 = cc[cc_index(i - 1, 3, k)] - cc[cc_index(ic - 1, 2, k)];
                tr3 = cc[cc_index(i - 1, 3, k)] + cc[cc_index(ic - 1, 2, k)];

                ch[ch_index(i - 1, k, 1)] = tr2 + tr3;
                cr3 = tr2 - tr3;
                ch[ch_index(i, k, 1)] = ti2 + ti3;
                ci3 = ti2 - ti3;
                cr2 = tr1 - tr4;
                cr4 = tr1 + tr4;
                ci2 = ti1 + ti4;
                ci4 = ti1 - ti4;

                // wa[x] originally had pointer -= 1 so I subtracted 1 from access index
                ch[ch_index(i - 1, k, 2)] = wa1[i - 3] * cr2 - wa1[i - 2] * ci2;
                ch[ch_index(i, k, 2)] = wa1[i - 3] * ci2 + wa1[i - 2] * cr2;
                ch[ch_index(i - 1, k, 3)] = wa2[i - 3] * cr3 - wa2[i - 2] * ci3;
                ch[ch_index(i, k, 3)] = wa2[i - 3] * ci3 + wa2[i - 1] * cr3;
                ch[ch_index(i - 1, k, 4)] = wa3[i - 3] * cr4 - wa3[i - 2] * ci4;
                ch[ch_index(i, k, 4)] = wa3[i - 3] * ci4 + wa3[i - 2] * cr4;
            }
        }

        if ido % 2 == 1 return;
    }

    for k: 1..l1 {
        ti1 = cc[cc_index(1, 2, k)] + cc[cc_index(1, 4, k)];
        ti2 = cc[cc_index(1, 4, k)] - cc[cc_index(1, 2, k)];
        tr1 = cc[cc_index(ido, 1, k)] - cc[cc_index(ido, 3, k)];
        tr2 = cc[cc_index(ido, 1, k)] + cc[cc_index(ido, 3, k)];
        ch[ch_index(ido, k, 1)] = tr2 + tr2;
        ch[ch_index(ido, k, 2)] = sqrt2 * (tr1 - ti1);
        ch[ch_index(ido, k, 3)] = ti2 + ti2;
        ch[ch_index(ido, k, 4)] = -sqrt2 * (tr1 + ti1);
    }
}

radb3 :: (ido: int, l1: int, cc: []float32, ch: []float32, wa1: []float32, wa2: []float32) {
    cc_offset, ch_offset, ic, idp2: int;
    ci2, ci3, di2, di3, cr2, cr3, dr2, dr3, ti2, tr2: float32;

    ch_offset = 1 + ido * (1 + l1);
    cc_offset = 1 + (ido << 2);

    radix := 3;

    /* Function Body */
    for k: 1..l1 {
        tr2 = cc[cc_index(ido, 2, k)] + cc[cc_index(ido, 2, k)];
        cr2 = cc[cc_index(1, 1, k)] + TAUR * tr2;
        ch[ch_index(1, k, 1)] = cc[cc_index(1, 1, k)] + tr2;
        ci3 = TAUI * (cc[cc_index(1, 3, k)] + cc[cc_index(1, 3, k)]);
        ch[ch_index(1, k, 2)] = cr2 - ci3;
        ch[ch_index(1, k, 3)] = cr2 + ci3;
    }

    if ido == 1 return;

    idp2 = ido + 2;

    for k: 1..l1 {
        i := 3;
        while i <= ido {
            defer i += 2;
            ic = idp2 - i;
            tr2 = cc[cc_index(i - 1, 3, k)] + cc[cc_index(ic - 1, 2, k)];
            cr2 = cc[cc_index(i - 1, 1, k)] + TAUR * tr2;
            ch[ch_index(i - 1, k, 1)] = cc[cc_index(i - 1, 1, k)] + tr2;
            ti2 = cc[cc_index(i, 3, k)] - cc[cc_index(ic, 2, k)];
            ci2 = cc[cc_index(i, 1, k)] + TAUR * ti2;
            ch[ch_index(i, k, 1)] = cc[cc_index(i, 1, k)] + ti2;
            cr3 = TAUI * (cc[cc_index(i - 1, 3, k)] - cc[cc_index(ic - 1, 2, k)]);
            ci3 = TAUI * (cc[cc_index(i, 3, k)] + cc[cc_index(ic, 2, k)]);
            dr2 = cr2 - ci3;
            dr3 = cr2 + ci3;
            di2 = ci2 + cr3;
            di3 = ci2 - cr3;

            ch[ch_index(i - 1, k, 2)] = wa1[i - 3] * dr2 - wa1[i - 2] * di2;
            ch[ch_index(i, k, 2)] = wa1[i - 3] * di2 + wa1[i - 2] * dr2;
            ch[ch_index(i - 1, k, 3)] = wa2[i - 3] * dr3 - wa2[i - 2] * di3;
            ch[ch_index(i, k, 3)] = wa2[i - 3] * di3 + wa2[i - 2] * dr3;
        }
    }
}

radb2 :: (ido: int, l1: int, cc: []float32, ch: []float32, wa1: []float32) {
    cc_offset, ch_offset: int;
    i, k, ic: int;
    ti2, tr2: float32;
    idp2: int;

    radix := 2;

    ch_offset = 1 + ido * (1 + l1);
    cc_offset = 1 + ido * 3;


    for k: 1..l1 {
        cc[cc_index(1, k, 1)] = cc[cc_index(1, 1, k)] + cc[cc_index(ido, 2, k)];
        ch[ch_index(1, k, 2)] = cc[cc_index(1, 1, k)] - cc[cc_index(ido, 2, k)];
    }

    if ido < 2 return;
    else if ido != 2 {
        idp2 = ido + 2;

        for k: 1..l1 {
            i := 3;
            while i <= ido {
                i += 2;
                ic = idp2 - i;
                ch[ch_index(i - 1, k, 1)] = cc[cc_index(i - 1, 1, k)] + cc[cc_index(ic - 1, 2, k)];
                tr2 = cc[cc_index(i - 1, 1, k)] - cc[cc_index(ic - 1, 2, k)];
                ch[ch_index(i, k, 1)] = cc[cc_index(i, 1, k)] - cc[cc_index(ic, 2, k)];
                ti2 = cc[cc_index(i, 1, k)] + cc[cc_index(ic, 2, k)];

                ch[ch_index(i - 1, k, 2)] = wa1[i - 3] * tr2 - wa1[i - 2] * ti2;
                ch[ch_index(i, k, 2)] = wa1[i - 3] * ti2 + wa1[i - 2] * tr2;
            }
        }

        if ido % 2 == 1 return;
    }

    for k: 1..l1 {
        ch[ch_index(ido, k, 1)] = cc[cc_index(ido, 1, k)] + cc[cc_index(ido, 1, k)];
        ch[ch_index(ido, k, 2)] = -(cc[cc_index(1, 2, k)] + cc[cc_index(1, 2, k)]);
    }
}

rfftb1 :: (n: int, c: []float32, ch: []float32, wa: []float32, ifac: []int) {
    /* Local variables */
    l1, l2, na, nf, ip, iw, ix2, ix3, ix4, ido, idl1: int;

    /* Function Body */
    nf = ifac[1];
    na = 0;
    l1 = 1;
    iw = 0;

    for k1: 1..nf {
        ip = ifac[k1 + 1];
        l2 = ip * l1;
        ido = n / l2;
        idl1 = ido * l1;

        if ip == {
        case 4;
            ix2 = iw + ido;
            ix3 = ix2 + ido;

            if na == 0 {
                radb4(ido, l1, c, ch,
                    array_view(wa, iw), array_view(wa, ix2), array_view(wa, ix3)
                );
            } else {
                radb4(ido, l1, ch, c,
                    array_view(wa, iw), array_view(wa, ix2), array_view(wa, ix3)
                );
            }

            na = 1 - na;
        case 2;
            if na == 0 {
                radb2(ido, l1, c, ch,
                    array_view(wa, iw)
                );
            } else {
                radb2(ido, l1, ch, c,
                    array_view(wa, iw)
                );
            }
            na = 1 - na;
        case 3;
            ix2 = iw + ido;

            if na == 0 {
                radb3(ido, l1, c, ch,
                    array_view(wa, iw), array_view(wa, ix2)
                );
            } else {
                radb3(ido, l1, ch, c,
                    array_view(wa, iw), array_view(wa, ix2)
                );
            }

            na = 1 - na;
        case 5;
            ix2 = iw + ido;
            ix3 = ix2 + ido;
            ix4 = ix3 + ido;

            if na == 0 {
                radb5(ido, l1, c, ch,
                    array_view(wa, iw), array_view(wa, ix2), array_view(wa, ix3), array_view(wa, ix4)
                );
            } else {
                radb5(ido, l1, ch, c,
                    array_view(wa, iw), array_view(wa, ix2), array_view(wa, ix3), array_view(wa, ix4)
                );
            }

            na = 1 - na;
        case;
            if na == 0 {
                radbg(ido, ip, l1, idl1, c, c, c, ch, ch,
                    array_view(wa, iw)
                );
            } else {
                radbg(ido, ip, l1, idl1, ch, ch, ch, c, c,
                    array_view(wa, iw)
                );
            }
            if ido == 1 {
                na = 1 - na;
            }
        }

        l1 = l2;
        iw += (ip - 1) * ido;
    }

    if na == 0 return;

    for 0..n-1 c[it] = ch[it];
}

__jfft_real_backward :: (n: int, r: []float, wsave: []float, ifac: []int) {
    if n == 1 return;

    rfftb1(n, r, wsave, array_view(wsave, n), ifac);
}

jfft_backward :: (jfft: *jfft_transformer, input: []float32) {
    #if 1 {
        if !__is_power_of_two(input.count) {
            print("[jfft] woah nelly! FFT on non-power-of-two buffers is very slow. Next power of two would be %.\n", __next_power_of_two(input.count));
            print("!!! comment this block out in `jfft_backward` if you really want to proceed, but don't say I didn't warn you. !!!");
            assert(false);
        }
    } else {
        assert(input.count % 2 == 0);
    }

    __jfft_real_backward(jfft.n, input, jfft.wsave, jfft.ifac);
    for 0..jfft.n-1 input[it] /= jfft.n;
}

jfft_backward_transform :: (input: []float32, allocator: Allocator = temp) {
    #if 1 {
        if !__is_power_of_two(input.count) {
            print("[jfft] woah nelly! FFT on non-power-of-two buffers is very slow. Next power of two would be %.\n", __next_power_of_two(input.count));
            print("!!! comment this block out in `jfft_backward_transform` if you really want to proceed, but don't say I didn't warn you. !!!");
            assert(false);
        }
    } else {
        assert(input.count % 2 == 0);
    }

    jfft := jfft_create_transformer(input.count, scale_output=scale_output, allocator=allocator);

    __jfft_real_backward(jfft.n, input, jfft.wsave, jfft.ifac);
    for 0..jfft.n-1 input[it] /= jfft.n; // always scale output

    jfft_destroy_transformer(jfft);
}