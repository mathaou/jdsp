#import "Basic" ()(MEMORY_DEBUGGER=true);
#import "File";
#import "String";

#load "sdl.jai";
#load "fft.jai";

sample_rate := 48000.0;
count := 0;

load_samples_from_wav :: (path: string) -> []float32 {
    #if 1 { // test data
        input := NewArray(2048 * 2, float32);

        for 0..(2048 * 2)-1 {
            input[it] = cos(2 * __M_PI / sample_rate * 10000 * it);
        }

        return input;
    } else {
        WAV_HEADER :: 58; // sometimes 44 bytes idk depends on the file

        file, success := file_open(path, for_writing=false, keep_existing_content=true);
        assert(success);

        length := file_length(file);
        length -= WAV_HEADER;

        n := 0;

        // do some fenagling to make the sample buffer a power of two
        prev := __previous_power_of_two(length);
        next := __next_power_of_two(length);

        pdiff := abs(length - prev);
        ndiff := abs(length - next);

        // go with the direction thats the shorter hop
        ifx pdiff > ndiff then n = next else n = prev;

        print("loaded % samples from %\n", n, path);
        buffer := cast([]float32) NewArray(n, u8, true);

        file_set_position(file, WAV_HEADER);
        success = file_read(file, buffer.data, length);
        assert(success);

        return buffer;
    }
}

input: []float32 : #run load_samples_from_wav("click.wav");
window_options := string.["None", "Parzen", "Welch", "Hanning", "Hamming", "Blackman", "Stepper"];

WIDTH :: 1920;
HEIGHT :: 1080;

main :: () {
    clear_color := make_vector4(0.45, 0.55, 0.60, 1.00);
    SDL_Init(SDL_INIT_VIDEO);

	window := SDL_CreateWindow(
		"jfft demo",
		SDL_WINDOWPOS_CENTERED,
		SDL_WINDOWPOS_CENTERED,
		WIDTH, HEIGHT,
		SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE | SDL_WINDOW_MAXIMIZED);

	if window == null {
        log("could not create window: %", to_string(SDL_GetError()));
        return;
    }

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);

    gl_context := SDL_GL_CreateContext(window);
    if !gl_context {
        log( "could not create OpenGL context: %", to_string(SDL_GetError()));
        return;
    }

    gl_load(*gl, SDL_GL_GetProcAddress);

    imgui_context := ImGui.CreateContext();

    ImGui_ImplSdl_Init(window);

    ImGui.StyleColorsClassic(); // dark theme all the way

    io := ImGui.GetIO();
    style := ImGui.GetStyle();

    style.GrabRounding = style.FrameRounding;

    done := false;

    cursor := 0;
    // always a power of two because we love ourselves
    input_length := input.count;

    current_range: []float32;
    range_copy: []float32;
    dB_copy: []float32;
    magnitude_copy: []float32;
    inverse_copy: []float32;
    window_copy: []float32;

    scale_output: bool;

    start: s64;
    sample_time: s64;

    buckets: [..]int;
    peaks: [..]float32;
    pause := false;

    window_selection := 0;
    selected_window := window_options[window_selection];

    transformer: *jfft_transformer;

    init_count :: (v: int) #expand {
        if v < 4 || v > 2048 return;

        if count != 0 {
            reset_temporary_storage();
            jfft_destroy_transformer(`transformer);
            array_reset(*`buckets);
        }

        assert(`input_length % v == 0); // sanity check
        `count = v;

        `transformer = jfft_create_transformer(`count, scale_output=`scale_output);

        `start, _ = to_microseconds(current_time_monotonic());
        `cursor = 0;
        `sample_time = xx (1.0 / `sample_rate * 1000000.0 * `count); // sample time in microseconds * number of samples

        i := 0;
        while i < v {
            defer i += 2;
            array_add(*`buckets, xx (i / 2 * sample_rate / v));
        }
    }

    // macro abuse I'm sorry
    next_block :: () #expand {
        if `cursor != 10000000 `cursor += `count;

        array_free(`range_copy);
        array_free(`magnitude_copy);
        array_free(`dB_copy);

        `current_range = array_view(`input, `cursor, `count);
        `range_copy = array_copy(`current_range);

        jfft_forward(`transformer, `range_copy);

        `dB_copy = array_copy(`range_copy);
        jfft_magnitude_db_transform(`dB_copy);

        `magnitude_copy = array_copy(`range_copy);
        jfft_magnitude_transform(`magnitude_copy);

        `inverse_copy = array_copy(`range_copy);
        jfft_backward(`transformer, `inverse_copy);

        `start, _ = to_microseconds(current_time_monotonic());
    }

    previous_block :: () #expand {
        if `cursor != 0 `cursor -= `count;

        array_free(`range_copy);
        array_free(`magnitude_copy);
        array_free(`dB_copy);

        `current_range = array_view(`input, `cursor, `count);
        `range_copy = array_copy(`current_range);

        jfft_forward(`transformer, `range_copy);

        `dB_copy = array_copy(`range_copy);
        jfft_magnitude_db_transform(`dB_copy);

        `magnitude_copy = array_copy(`range_copy);
        jfft_magnitude_transform(`magnitude_copy);

        `inverse_copy = array_copy(`range_copy);
        jfft_backward(`transformer, `inverse_copy);

        `start, _ = to_microseconds(current_time_monotonic());
    }

    init_count(128);

    while !done {
        event: SDL_Event;
        while SDL_PollEvent(*event) {
            ImGui_ImplSdl_ProcessEvent(*event);
            if event.type == {
            case SDL_QUIT;
                done = true;
            case SDL_KEYDOWN;
                if event.key.keysym.sym == SDLK_ESCAPE done = true;
                if event.key.keysym.sym == SDLK_SPACE {
                    pause = !pause;
                }
                if event.key.keysym.sym == SDLK_l {
                    sample_time += 10000;
                    if sample_time >= 10000000 sample_time = 10000000; // 10 seconds max

                    start, _ = to_microseconds(current_time_monotonic());
                }
                if event.key.keysym.sym == SDLK_k {
                    sample_time -= 10000;
                    if sample_time < 0 sample_time = 0;

                    start, _ = to_microseconds(current_time_monotonic());
                }
                if pause && event.key.keysym.sym == SDLK_RIGHT {
                    next_block();
                }
                if pause && event.key.keysym.sym == SDLK_LEFT {
                    previous_block();
                }
                if event.key.keysym.sym == SDLK_UP {
                    init_count(count << 1);
                }
                if event.key.keysym.sym == SDLK_DOWN {
                    init_count(count >> 1);
                }
            case SDL_WINDOWEVENT;
                if event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == SDL_GetWindowID(window) {
                    done = true;
                }
            }
        }

        ImGui_ImplSdl_NewFrame(window);
        ImGui.NewFrame();

		ImGui.SetNextWindowSize(ImGui.GetIO().DisplaySize, .ImGuiCond_Always);
        ImGui.SetNextWindowPos(.{0, 0}, .ImGuiCond_Always);

        ImGui.Begin("##main", null,
        	.ImGuiWindowFlags_NoTitleBar |
        	.ImGuiWindowFlags_NoCollapse |
        	.ImGuiWindowFlags_NoResize |
        	.ImGuiWindowFlags_NoMove |
        	.ImGuiWindowFlags_NoScrollbar
        );

        {
            if cursor == input_length - count {
                cursor = 0;
                init_count(count);
            }

            current, _ := to_microseconds(current_time_monotonic());
            range := sprint("% - %", cursor, cursor + count);

            if !pause && current - start >= sample_time { // only update based on sample_rate
                current_range = array_view(input, cursor, count);
                range_copy = array_copy(current_range);
                cursor += count;

                jfft_forward(transformer, range_copy);

                dB_copy = array_copy(range_copy);
                jfft_magnitude_db_transform(dB_copy);

                magnitude_copy = array_copy(range_copy);
                jfft_magnitude_transform(magnitude_copy);

                inverse_copy = array_copy(range_copy);
                jfft_backward(transformer, inverse_copy);

                start, _ = to_microseconds(current_time_monotonic());
            }

            ImGui.Text(sprint("updating every % usec", sample_time));

            ImGui.SameLine();

            before := scale_output;

            ImGui.Checkbox("Scale Output", *scale_output);

            ImGui.SameLine();

            if ImGui.BeginCombo("Window", selected_window.data, 0) {
                defer ImGui.EndCombo();

                for window_options {
                    is_selected := window_selection == it_index;
                    if ImGui.Selectable(window_options[it_index].data, is_selected) {
                        window_selection = it_index;
                        selected_window = it;
                    }

                    if is_selected {
                        ImGui.SetItemDefaultFocus();
                    }
                }
            }

            ImGui.SameLine();

            if ImGui.BeginCombo("Filter", selected_window.data, 64) {
                defer ImGui.EndCombo();

                for window_options {
                    is_selected := window_selection == it_index;
                    if ImGui.Selectable(window_options[it_index].data, is_selected) {
                        window_selection = it_index;
                        selected_window = it;
                    }

                    if is_selected {
                        ImGui.SetItemDefaultFocus();
                    }
                }
            }

            if before != scale_output {
                init_count(count);
            }

            ImGui.PlotLines("Original Signal".data, current_range.data, xx current_range.count, 0, range.data, -1, 1,
                .{xx (io.DisplaySize.x - 150), xx (io.DisplaySize.y / 4 - 50)});

            if compare_nocase(selected_window, "None") != 0 {
                window: jfft_window;
                using jfft_window;

                if selected_window == {
                case "Parzen";
                    window = PARZEN;
                case "Welch";
                    window = WELCH;
                case "Hanning";
                    window = HANNING;
                case "Hamming";
                    window = HAMMING;
                case "Blackman";
                    window = BLACKMAN;
                case "Stepper";
                    window = STEPPER;
                }

                window_copy = apply_window(current_range, window);
                ImGui.PlotLines("Modified Signal".data, window_copy.data, xx window_copy.count, 0, range.data, -1, 1,
                    .{xx (io.DisplaySize.x - 150), xx (io.DisplaySize.y / 4 - 50)});
            }

            // half the bins are used for results, N / 2 + 1 is nyquist\
            max: float32;

            for 0..(magnitude_copy.count / 2) {
                if magnitude_copy[it] > max max = magnitude_copy[it];
            }

            ImGui.PlotHistogram("".data, magnitude_copy.data, xx (magnitude_copy.count / 2), 0, range.data, 0, max,
                .{xx (io.DisplaySize.x / 2), xx (io.DisplaySize.y / 4 - 50)});

            ImGui.SameLine();

            ImGui.PlotHistogram("jfft magnitude/dB".data, dB_copy.data, xx (dB_copy.count / 2), 0, range.data, -60, 30,
                .{xx (io.DisplaySize.x / 2 - 158), xx (io.DisplaySize.y / 4 - 50)});

            ImGui.PlotLines("jfft inverse".data, inverse_copy.data, xx (inverse_copy.count / 2), 0, range.data, -200, 200,
                .{xx (io.DisplaySize.x - 150), xx (io.DisplaySize.y / 4 - 50)});

            // for buckets {
            //     array_add(*peaks, xx it);
            // }

            // ImGui.PlotHistogram("frequency legend".data, peaks.data, xx peaks.count, 0, "".data, 0, xx (sample_rate / 2),
            //     .{xx (io.DisplaySize.x - 150), xx (io.DisplaySize.y / 4 - 50)});

            // array_reset(*peaks);
        }

        ImGui.End();

        ImGui.Render();
        glViewport(0, 0, xx io.DisplaySize.x, xx io.DisplaySize.y);
        glClearColor(clear_color.x, clear_color.y, clear_color.z, clear_color.w);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        SDL_GL_SwapWindow(window);
    }

    // Cleanup
    ImGui_ImplSdl_Shutdown();
    ImGui.DestroyContext(imgui_context);
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();
}