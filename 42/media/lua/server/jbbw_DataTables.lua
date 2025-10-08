-- JB's Big Wood Tables for 12

JB_Big_Wood = JB_Big_Wood or {}
JB_Big_Wood.data = JB_Big_Wood.data or {}
require "jbbw_ModOptions"
require "jbbw_Utils"

JB_Big_Wood.data = {
    ["shovels"] = {
        ["SpadeForged"] = true,
        ["Shovel2"] = true,
        ["Shovel"] = true
    },

    ["diggingTools"] = {
        ["PickAxe"] = true,
    },

    ["logTypes"] = {
        ["Base.Log"] = true,
        ["JB_Big_Wood.LogBolt"] = true,
        ["JB_Big_Wood.SmallLog"] = true,
        ["JB_Big_Wood.LargeLog"] = true,
        ["JB_Big_Wood.VeryLargeLog"] = true,
    },
}

JB_Big_Wood.treeDrops = {
    [1] = {
        size = "Seedling",
        type = "Base.Twigs",
        drops = {
            exclusive = {
                { item = "Base.Twigs", chance = 0.5 },
            },
            normal = {
                { item = "Base.Splinters", chance = 1 },
            },
        },
    },
    [2] = {
        size = "Small",
        type = "Base.Sapling",
        drops = {
            exclusive = {
                { item = "Base.Twigs",   chance = 0.2 },
                { item = "Base.Sapling", chance = 0.8 },
            },
            normal = {
                { item = "Base.Splinters",   chance = 1 },
                { item = "Base.TreeBranch2", chance = 0.2 },
                { item = "Base.WildEggs",    chance = 0.05 },
            },
        },
    },
    [3] = {
        size = "Medium",
        type = "JB_Big_Wood.SmallLog",
        drops = {
            exclusive = {
                { item = "JB_Big_Wood.SmallLog", chance = 0.7 },
                { item = "Base.Sapling",         chance = 0.3 },
            },
            normal = {
                { item = "Base.Splinters",    chance = 1 },
                { item = "Base.Twigs",        chance = 0.8 },
                { item = "Base.TreeBranch2",  chance = 0.2 },
                { item = "Base.WildEggs",     chance = 0.05 },
                { item = "Base.DeadSquirrel", chance = 0.05 },
            },
        },
    },
    [4] = {
        size = "Large",
        type = "JB_Big_Wood.LargeLog",
        drops = {
            exclusive = {
                { item = "JB_Big_Wood.LargeLog", chance = 1.0 },
            },
            normal = {
                { item = "Base.Twigs",        chance = 0.7 },
                { item = "Base.Splinters",    chance = 1 },
                { item = "Base.TreeBranch2",  chance = 0.8 },
                { item = "Base.LargeBranch",  chance = 0.5 },
                { item = "Base.WildEggs",     chance = 0.05 },
                { item = "Base.DeadSquirrel", chance = 0.05 },
                { item = "Base.DeadBird",     chance = 0.05 },

            },
        },
    },
    [5] = {
        size = "V. Large",
        type = "JB_Big_Wood.VeryLargeLog",
        drops = {
            exclusive = {
                { item = "JB_Big_Wood.VeryLargeLog", chance = 0.3 },
                { item = "JB_Big_Wood.LargeLog",     chance = 0.7 },
            },
            normal = {
                { item = "Base.Twigs",        chance = 0.8 },
                { item = "Base.Splinters",    chance = 1 },
                { item = "Base.TreeBranch2",  chance = 0.5 },
                { item = "Base.LargeBranch",  chance = 0.8 },
                { item = "Base.WildEggs",     chance = 0.05 },
                { item = "Base.DeadSquirrel", chance = 0.05 },
                { item = "Base.DeadBird",     chance = 0.05 },
            },
        },
    }
}

JB_Big_Wood.treeTable =
{
    ["americanholly"] = {
        ["logTexture"] = "jb_log_americanholly",
        ["displayName"] = "American Holly",
        ["treeStump"] = {
            [3] = "jbbw_TreeStumps_0",
            [4] = "jbbw_TreeStumps_0",
            [5] = "jbbw_TreeStumps_1",
            [6] = "jbbw_TreeStumps_3"
        }
    },
    ["americanlinden"] = {
        ["logTexture"] = "jb_log_americanlinden",
        ["displayName"] = "American Linden",
        ["treeStump"] = {
            [3] = "jbbw_TreeStumps_0",
            [4] = "jbbw_TreeStumps_0",
            [5] = "jbbw_TreeStumps_1",
            [6] = "jbbw_TreeStumps_2"
        }
    },
    ["canadianhemlock"] = {
        ["logTexture"] = "jb_log_canadianhemlock",
        ["displayName"] = "Canadian Hemlock",
        ["treeStump"] = {
            [3] = "jbbw_TreeStumps_0",
            [4] = "jbbw_TreeStumps_1",
            [5] = "jbbw_TreeStumps_2",
            [6] = "jbbw_TreeStumps_2"
        }
    },
    ["carolinasilverbell"] = {
        ["logTexture"] = "jb_log_carolinasilverbell",
        ["displayName"] = "Carolina Silverbell",
        ["treeStump"] = {
            [3] = "jbbw_TreeStumps_0",
            [4] = "jbbw_TreeStumps_0",
            [5] = "jbbw_TreeStumps_1",
            [6] = "jbbw_TreeStumps_1"
        }
    },
    ["cockspurhawthorn"] = {
        ["logTexture"] = "jb_log_cockspurhawthorn",
        ["displayName"] = "Cockspur Hawthorn",
        ["treeStump"] = {
            [3] = "jbbw_TreeStumps_0",
            [4] = "jbbw_TreeStumps_1",
            [5] = "jbbw_TreeStumps_2",
            [6] = "jbbw_TreeStumps_2"
        }
    },
    ["dogwood"] = {
        ["logTexture"] = "jb_log_dogwood",
        ["displayName"] = "Dogwood",
        ["treeStump"] = {
            [3] = "jbbw_TreeStumps_0",
            [4] = "jbbw_TreeStumps_1",
            [5] = "jbbw_TreeStumps_3",
            [6] = "jbbw_TreeStumps_3"
        }
    },
    ["easternredbud"] = {
        ["logTexture"] = "jb_log_easternredbud",
        ["displayName"] = "Eastern Redbud",
        ["treeStump"] = {
            [3] = "jbbw_TreeStumps_0",
            [4] = "jbbw_TreeStumps_1",
            [5] = "jbbw_TreeStumps_3",
            [6] = "jbbw_TreeStumps_3"
        }
    },
    ["riverbirch"] = {
        ["logTexture"] = "jb_log_riverbirch",
        ["displayName"] = "River Birch",
        ["treeStump"] = {
            [3] = "d_generic_1_28",
            [4] = "d_generic_1_28",
            [5] = "d_generic_1_28",
            [6] = "d_generic_1_28"
        }
    },
    ["virginiapine"] = {
        ["logTexture"] = "jb_log_virginiapine",
        ["displayName"] = "Virgina Pine",
        ["treeStump"] = {
            [3] = "jbbw_TreeStumps_0",
            [4] = "jbbw_TreeStumps_1",
            [5] = "jbbw_TreeStumps_1",
            [6] = "jbbw_TreeStumps_2"
        }
    },
    ["yellowwood"] = {
        ["logTexture"] = "jb_log_yellowwood",
        ["displayName"] = "Yellowwood",
        ["treeStump"] = {
            [3] = "jbbw_TreeStumps_0",
            [4] = "jbbw_TreeStumps_1",
            [5] = "jbbw_TreeStumps_1",
            [6] = "jbbw_TreeStumps_2"
        }
    },
    ["redmaple"] = {
        ["logTexture"] = "jb_log_redmaple",
        ["displayName"] = "Red Maple",
        ["treeStump"] = {
            [3] = "jbbw_TreeStumps_0",
            [4] = "jbbw_TreeStumps_1",
            [5] = "jbbw_TreeStumps_3",
            [6] = "jbbw_TreeStumps_3"
        }
    }
}

return JB_Big_Wood