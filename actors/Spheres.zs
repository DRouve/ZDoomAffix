class ZDA_Sphere : Inventory {}

// orb of transmutation
class ZDA_SphereOfTransfiguration : ZDA_Sphere {
    Default {
        Scale 0.5;
    }
    States
    {
        Spawn:
            DAST A -1 Bright;
            Stop;
    } 
}
class ZDA_DevelopmentDatachip : ZDA_SphereOfTransfiguration {
    Default {
        Scale 0.25;
    }
    States
    {
        Spawn:
            DADD A -1 Bright;
            Stop;
    } 
}

// orb of alteration
class ZDA_SphereOfMetamorphosis : ZDA_Sphere {
    Default {
        Scale 0.5;
    }
    States
    {
        Spawn:
            DASM A -1 Bright;
            Stop;
    } 
}
class ZDA_ReconstructionDatachip : ZDA_SphereOfMetamorphosis {
    Default {
        Scale 0.25;
    }
    States
    {
        Spawn:
            DARD A -1 Bright;
            Stop;
    } 
}

// orb of alchemy
class ZDA_SphereOfSorcery : ZDA_Sphere {
    Default {
        Scale 0.5;
    }
    States
    {
        Spawn:
            DASS A -1 Bright;
            Stop;
    } 
}
class ZDA_ChemistryDatachip : ZDA_SphereOfSorcery {
    Default {
        Scale 0.25;
    }
    States
    {
        Spawn:
            DACD A -1 Bright;
            Stop;
    } 
}

// regal orb
class ZDA_SphereOfMajesty : ZDA_Sphere {
    Default {
        Scale 0.5;
    }
    States
    {
        Spawn:
            DASM B -1 Bright;
            Stop;
    } 
}
class ZDA_IntegrityDatachip : ZDA_SphereOfMajesty {
    Default {
        Scale 0.25;
    }
    States
    {
        Spawn:
            DAID A -1 Bright;
            Stop;
    } 
}

// chaos orb
class ZDA_SphereOfHavoc : ZDA_Sphere {
    Default {
        Scale 0.5;
    }
    States
    {
        Spawn:
            DASH A -1 Bright;
            Stop;
    } 
}
class ZDA_EntropyDatachip : ZDA_SphereOfHavoc {
    Default {
        Scale 0.25;
    }
    States
    {
        Spawn:
            DAED A -1 Bright;
            Stop;
    } 
}

// exalted orb
class ZDA_SphereOfWorthy : ZDA_Sphere {
    Default {
        Scale 0.5;
    }
    States
    {
        Spawn:
            DASW A -1 Bright;
            Stop;
    } 
}
class ZDA_CoreDatachip : ZDA_SphereOfWorthy {
    Default {
        Scale 0.25;
    }
    States
    {
        Spawn:
            DACD A -1 Bright;
            Stop;
    } 
}

// divine orb
class ZDA_SphereOfDeity : ZDA_Sphere {
    Default {
        Scale 0.5;
    }
    States
    {
        Spawn:
            DASD A -1 Bright;
            Stop;
    } 
}
class ZDA_TheologyDatachip : ZDA_SphereOfDeity {
    Default {
        Scale 0.25;
    }
    States
    {
        Spawn:
            DATD A -1 Bright;
            Stop;
    } 
}

// vaal orb
class ZDA_SphereOfCorruption : ZDA_Sphere {
    Default {
        Scale 0.5;
    }
    States
    {
        Spawn:
            DASC A -1 Bright;
            Stop;
    } 
}
class ZDA_EncryptionDatachip : ZDA_SphereOfCorruption {
    Default {
        Scale 0.25;
    }
    States
    {
        Spawn:
            DAND A -1 Bright;
            Stop;
    } 
}