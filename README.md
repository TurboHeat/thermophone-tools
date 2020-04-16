# Multilayer model of thermoacoustic sound generation in steady periodic operation

Code for simulating thermophones, based upon 

> Guiraud, Pierre, et al. "_Multilayer modeling of thermoacoustic sound generation for thermophone analysis and design._" Journal of Sound and Vibration 455 (2019): 275-298. [DOI](https://doi.org/10.1016/j.jsv.2019.05.001)

The implemented model considers:

* Constant volumetric generation
* Boundary generation
* Convective losses

This simulator uses the non-free Multiprecision Computing Toolbox for MATLAB (aka `mp` toolbox) to perform some computations that require increased precision.

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
    |    5   | _μ_                   | 1ˢᵗ viscosity coeff.                |   [kg m⁻¹ s⁻¹]  |
    |    6   | _λ_                   | 2ⁿᵈ viscosity coeff.                |   [kg m⁻¹ s⁻¹]  |
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

1. **Running in `parfor` mode**  
If `Backend_codes.Solution_function` is configured to run using `parfor`, it is necessary to initialize the `mp` toolbox on each node (i.e. worker of the parallel pool) using the following commands:

    ```matlab
    parpool(); % Create a pool with the default settings
    spmd       % Issue commands to all workers in pool (Single Program, Multiple Data)
      warning('off', 'MATLAB:nearlySingularMatrix') % Precision warning toggle
      mp.Digits(50);                                % mp toolbox precision setup
    end
    ```

1. **Enabling/disabling the progress bar**  
A progress bar visualizes the progress of loop `for` or `parfor` A progress bar is always associated with some overhead, however, in cases where individual loop iterations are very short (i.e. the "business logic" takes a short time to execute), the overhead can be the main performance sink - as happens in this case - which is why it is commented out in the code. 

    The `ParforProgressbar` utility is bundled with the code as a Git submodule. To enable `progressbar` one must add it to MATLAB's path (e.g. `addpath(fullfile(pwd, 'progressbar'));`), and uncomment the lines related to `ppm` in `Solution_function.m` (3 lines in total).
    