#
# Example 2
# Phase change driven by a mechanical (elastic) driving force.
# An oversized phase inclusion grows under a uniaxial tensile stress.
# Check the file below for comments and suggestions for parameter modifications.
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 40
  ny = 40
  nz = 0
  xmin = 0
  xmax = 50
  ymin = 0
  ymax = 50
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  [./eta]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = SmoothCircleIC
      x1 = 0
      y1 = 0
      radius = 30.0
      invalue = 1.0
      outvalue = 0.0
      int_width = 10.0
    [../]
  [../]
  [./disp_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
  [./TensorMechanics]
    displacements = 'disp_x disp_y'
  [../]

  [./eta_bulk]
    type = AllenCahn
    variable = eta
    f_name = F
  [../]
  [./eta_interface]
    type = ACInterface
    variable = eta
    kappa_name = 1
  [../]
  [./time]
    type = TimeDerivative
    variable = eta
  [../]


[]

#
# Try visualizing the stress tensor components as done in Conserved.i
#

[Materials]
  [./consts]
    type = GenericConstantMaterial
    block = 0
    prop_names  = 'L'
    prop_values = '1'
  [../]


  # simple chemical free energy
  [./chemical_free_energy]
    type = DerivativeParsedMaterial
    block = 0
    f_name = Feta
    args = 'eta'
#    constant_names       = 'm'
#    constant_expressions = '1.0'
#function = eta*(1-eta)*m+eta*(1-eta)*eta*(1-eta)
    function = 2*(-0.5*(eta-1)*(eta-1)+0.25*(eta-1)*(eta-1)*(eta-1)*(eta-1))-0.02*15/16.*((eta-1)-2/3.*(eta-1)*(eta-1)*(eta-1)+0.2*(eta-1)*(eta-1)*(eta-1)*(eta-1)*(eta-1))
    enable_jit = true
    derivative_order = 2
  [../]

  # matrix phase
  [./stiffness_a]
    type = ComputeElasticityTensor
    base_name = phasea
    block = 0
    # lambda, mu values
    C_ijkl = '7 7'
    # Stiffness tensor is created from lambda=7, mu=7 for symmetric_isotropic fill method
    fill_method = symmetric_isotropic
    # See RankFourTensor.h for details on fill methods
  [../]
  [./strain_a]
    type = ComputeSmallStrain
    block = 0
    displacements = 'disp_x disp_y'
    base_name = phasea
  [../]
  [./stress_a]
    type = ComputeLinearElasticStress
    block = 0
    base_name = phasea
  [../]
  [./elastic_free_energy_a]
    type = ElasticEnergyMaterial
    base_name = phasea
    f_name = Fea
    block = 0
    args = ''
  [../]

  # oversized precipitate phase (simulated using thermal expansion)
  [./stiffness_b]
    type = ComputeElasticityTensor
    base_name = phaseb
    block = 0
    # Stiffness tensor lambda, mu values
    # Note that the two phases could have different stiffnesses.
    # Try reducing the precipitate stiffness (to '1 1') rather than making it oversized
    C_ijkl = '1 1'
    fill_method = symmetric_isotropic
  [../]
  [./strain_b]
    type = ComputeSmallStrain
    block = 0
    displacements = 'disp_x disp_y'
    base_name = phaseb
    # we use thermal expansion with a constant temperature to achieve a 10% oversize
    # commenting out the following 3 lines will switch off the oversize effect
    thermal_expansion_coeff = 0.0  #0.1
    temperature_ref = 0
    temperature = 0     #1
  [../]
  [./stress_b]
    type = ComputeLinearElasticStress
    block = 0
    base_name = phaseb
  [../]
  [./elastic_free_energy_b]
    type = ElasticEnergyMaterial
    base_name = phaseb
    f_name = Feb
    block = 0
    args = ''
  [../]

  # Generate the global free energy from the phase free energies
  [./switching]
    type = SwitchingFunctionMaterial
    block = 0
    eta = eta
    h_order = SIMPLE
  [../]
  [./barrier]
    type = BarrierFunctionMaterial
    block = 0
    eta = eta
    g_order = SIMPLE
  [../]
#  [./free_energy]
#    type = DerivativeTwoPhaseMaterial
#    block = 0
#    f_name = F
#    fa_name = Fea
#    fb_name = Feb
#    eta = eta
#    args = ''
#    W = 0.1
#    derivative_order = 2
#  [../]

  [./free_energy_elasticsum]
    type = DerivativeTwoPhaseMaterial
    block = 0
    f_name = F_elas
    fa_name = Fea
    fb_name = Feb
    eta = eta
    args = ''
    W = 0
    derivative_order = 2
  [../]

  # Sum up chemical and elastic contributions
  [./free_energy]
    type = DerivativeSumMaterial
    block = 0
    f_name = F
#    sum_materials = 'Feta Fea Feb'
    sum_materials = 'Feta F_elas'
    args = 'eta'
    derivative_order = 2
  [../]

  # Generate the global stress from the phase stresses
  [./global_stress]
    type = TwoPhaseStressMaterial
    block = 0
    base_A = phasea
    base_B = phaseb
  [../]
[]

[BCs]
  [./bottom_y]
    type = PresetBC
    variable = disp_y
    boundary = 'bottom'
    value = 0
  [../]
  [./top_y]
    type = PresetBC
    variable = disp_y
    boundary = 'top'
    value = 5
  [../]
  [./left_x]
    type = PresetBC
    variable = disp_x
    boundary = 'left'
    value = 0
  [../]
[]

[Preconditioning]
  # active = ' '
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2

  # this gives best performance on 4 cores
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type  -sub_pc_type '
  petsc_options_value = 'asm       lu'

  l_max_its = 30
  nl_max_its = 10
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-8
  nl_abs_tol = 1.0e-10
  start_time = 0.0
  num_steps = 200

  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    dt = 0.2
  [../]
[]

[Outputs]
  execute_on = 'timestep_end'
  exodus = true
[]
