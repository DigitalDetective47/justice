---@param args {to_key: integer}
function G.FUNCS.printf_notationTypes(args)
    SMODS.Mods.NumberFormat.config.scientific.notationType = args.to_key
end

---@param slider table
function G.FUNCS.printf_sliderFloor(slider)
    slider.ref_table[slider.ref_value] = math.floor(slider.ref_table[slider.ref_value] + 0.5)
end

function SMODS.current_mod.config_tab()
    return {
        n = G.UIT.ROOT,
        config = { r = 0.1, colour = G.C.BLACK, emboss = 0.05 },
        nodes = { {
            n = G.UIT.C,
            config = { align = "ct", minw = 7 },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        { n = G.UIT.T, config = { text = localize("switchPoint", "printf_UI"), scale = 0.2, colour = G.C.UI.TEXT_LIGHT } },
                        create_slider({
                            min = -1,
                            max = 20,
                            ref_table = SMODS.Mods.NumberFormat.config,
                            ref_value = "switchPoint",
                            w = 4,
                            h = 0.4,
                            callback = "printf_sliderFloor",
                        })
                    }
                },
                { n = G.UIT.R, config = { minh = 0.1 } },
                {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        { n = G.UIT.T, config = { text = localize("decimalPoint", "printf_UI"), scale = 0.4, colour = G.C.UI.TEXT_LIGHT } },
                        create_text_input({
                            current_prompt_text = SMODS.Mods.NumberFormat.config.decimalPoint,
                            ref_table = SMODS.Mods.NumberFormat.config,
                            ref_value = "decimalPoint",
                            extended_corpus = true,
                        })
                    }
                },
                { n = G.UIT.R, config = { minh = 0.4 } },
                { n = G.UIT.R, nodes = { { n = G.UIT.T, config = { text = localize("h_standard", "printf_UI"), scale = 1, colour = G.C.UI.TEXT_LIGHT } } } },
                { n = G.UIT.R, config = { minh = 0.1 } },
                {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        { n = G.UIT.T, config = { text = localize("thousandsSeparator", "printf_UI"), scale = 0.4, colour = G.C.UI.TEXT_LIGHT } },
                        create_text_input({
                            current_prompt_text = SMODS.Mods.NumberFormat.config.standard.thousandsSeparator,
                            ref_table = SMODS.Mods.NumberFormat.config.standard,
                            ref_value = "thousandsSeparator",
                            extended_corpus = true,
                        })
                    }
                },
                { n = G.UIT.R, config = { minh = 0.4 } },
                { n = G.UIT.R, nodes = { { n = G.UIT.T, config = { text = localize("h_scientific", "printf_UI"), scale = 1, colour = G.C.UI.TEXT_LIGHT } } } },
                { n = G.UIT.R, config = { minh = 0.1 } },
                create_option_cycle({
                    options = G.localization.misc.printf_notationTypes,
                    opt_callback = "printf_notationTypes",
                    current_option = SMODS.Mods.NumberFormat.config.scientific.notationType
                }),
                { n = G.UIT.R, config = { minh = 0.1 } },
                {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        { n = G.UIT.T, config = { text = localize("digits", "printf_UI"), scale = 0.2, colour = G.C.UI.TEXT_LIGHT } },
                        create_slider({
                            min = 0,
                            max = 17,
                            ref_table = SMODS.Mods.NumberFormat.config.scientific,
                            ref_value = "digits",
                            w = 4,
                            h = 0.4,
                            callback = "printf_sliderFloor",
                        })
                    }
                },
                { n = G.UIT.R, config = { minh = 0.1 } },
                {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        { n = G.UIT.T, config = { text = localize("infName", "printf_UI"), scale = 0.4, colour = G.C.UI.TEXT_LIGHT } },
                        create_text_input({
                            current_prompt_text = SMODS.Mods.NumberFormat.config.infName,
                            ref_table = SMODS.Mods.NumberFormat.config,
                            ref_value = "infName",
                            extended_corpus = true,
                        })
                    }
                },
            }
        } }

    }
end

return {
    switchPoint = 11,
    decimalPoint = ".",
    standard = {
        thousandsSeparator = ",",
    },
    scientific = {
        notationType = 1,
        digits = 4,
    },
    infName = "naneinf",
}
