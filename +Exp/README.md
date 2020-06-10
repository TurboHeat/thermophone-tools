# Multilayer model of thermoacoustic sound generation in steady periodic operation
# Thermophone experiment post-processing 

Incorporates Code for simulating thermophones, based upon 

> Guiraud, Pierre, et al. "_Multilayer modeling of thermoacoustic sound generation for thermophone analysis and design._" Journal of Sound and Vibration 455 (2019): 275-298. [DOI](https://doi.org/10.1016/j.jsv.2019.05.001)

The implemented model considers:

* Constant volumetric generation
* Boundary generation
* Convective losses

Also incorporates the facility to retroactively calculate boundary layer conditions from experimental measurements. The code reads the experimental output files which contain the following measurements, and calibrates if necessary:

* Circuit voltages (Volts)
* Circuit resistances (Ohms)
* Microphone readings (Pa)
* Accelerometer readings (m/s2)
* Thermopile heat flux (W/m2)
* Thermocouple readings (C)
* Ambient pressure readings (Pa)

The code outputs the heat-flux at the boundary due to the thermophone, as well as the work done by the vibrating 'solid-drive', and finds the ratio between them. In parallel, the code 'simulates' the experiment with the thermophone model in order to provide a prediction.

--------------

## How to use the code:

The code is run by executing the thermophoneExperimentExample.m code. Within this file, the filename identifier of the experimental data is input. 

The code automatically checks for additional datafiles that have the same name (the overflow due to large data samples).  

The experimental thermophone design is input into the verificationCase_exp.m code. The code automatically calculates the power input and updates the power setting in the verification case. The code therefore simulates the case in parallel to processing the data in order to provide insight into the physics.

Sensor calibration parameters can be changed in the CalibOpts.m code. The results file and definitions can be found in ThermophoneEXPResults.m file.


--------------

## Prerequisites

The simulator uses the non-free Multiprecision Computing Toolbox for MATLAB (aka `mp` toolbox) to perform some computations that require increased precision.

Contents:

* [Preparations](#prep)
* [Simulator Configuration](#config)

--------------

<a name="prep"></a>

## Preparations

### Multiprecision Computing Toolbox for MATLAB

  1. Download:
     * [Windows](https://www.advanpix.com/wp-content/plugins/download-monitor/download.php?id=1) 
     * [Linux](https://www.advanpix.com/wp-content/plugins/download-monitor/download.php?id=8)
     * [Mac](https://www.advanpix.com/wp-content/plugins/download-monitor/download.php?id=9)
  
  1. Install:
     * On Windows - install, on Mac/Linux - extract.
     * Add the toolbox to MATLAB's PATH using the `path` tool or:

        ```matlab
        addpath('path/to/AdvanpixMCT-4.7.0-1.13589')
        ```

  1. Trial reset:  
     A method for doing this has only been discovered on **Windows** so far, and consists of going to `%APPDATA%/MathWorks/MATLAB`, then opening each of the `R20###` folders and **deleting** the empty folder of `CommandHistory`.

--------------

<a name="config"></a>

## Simulator Configuration

1. **Layer definitions**  
Data of each material layer is included in a matrix called `MDM` (**M**aterial **D**ata **M**atrix). Each row represents the properties of a different layer of the thermophone design,
in the order in which they appear. The column inputs are as follows:

    #### Material properties:

    | Col. # |         Symbol        | Description                         |      Units      |
    |:------:|:---------------------:|-------------------------------------|:---------------:|
    |    1   |  _L_                  | Thickness                           |       [m]       |
    |    2   |  _ρ_                  | Density                             |     [kg m⁻³]    |
    |    3   |  _B_                  | Bulk modulus                        |       [Pa]      |
    |    4   | _α<sub>T</sub>_       | Coeff. thermal expansion            |      [K⁻¹]      |
    |    5   | _λ_                   | 1ˢᵗ viscosity coeff.                |   [kg m⁻¹ s⁻¹]  |
    |    6   | _μ_                   | 2ⁿᵈ viscosity coeff.                |   [kg m⁻¹ s⁻¹]  |
    |    7   | _c<sub>p</sub>_       | Specific heat, constant pressure    |   [J kg⁻¹ K⁻¹]  |
    |    8   | _c<sub>v</sub>_       | Specific heat, constant volume      |   [J kg⁻¹ K⁻¹]  |
    |    9   | _κ_                   | Thermal conductivity                |   [W m⁻¹ K⁻¹]   |

    #### Forcing parameters

    | Col. # |      Symbol      |  Description                 | Units |
    |:------:|:----------------:|------------------------------|:-----:|
    |   10   | _S<sub>L</sub>_  | Lt. edge boundary generation |  [W]  |
    |   11   | _S<sub>0</sub>_  | Internal generation          |  [W]  |
    |   12   | _S<sub>R</sub>_  | Rt. edge boundary generation |  [W]  |

    #### Experimental Conditions

    | Col. # | Symbol | Description                             |      Units     |
    |:------:|:------:|-----------------------------------------|:--------------:|
    |   13   |  _h<sub>L</sub>_ | Lt. edge heat transfer coeff. |  [W m⁻¹ K⁻²]   |
    |   14   |  _T<sub>0</sub>_ | Internal mean temperature     |      [K]       |
    |   15   |  _h<sub>R</sub>_ | Rt. edge heat transfer coeff. |  [W m⁻¹ K⁻²]   |

    ### Visualized example structure

    ```matlab
    MDM = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14;...%(layer 1)
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14;...%(layer 2)
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14;...%(layer 3)
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ]; %(layer 4)
    ```
    