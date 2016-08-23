#
# Example problem showing how to use the DerivativeParsedMaterial with AllenCahn.
# The free energy is f_bulk = 1/4*(1-c)^2*(1+c)^2.
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
  xmax = 60
  ymax = 60
[]

[Variables]
#  [./c]
#    order = THIRD
#    family = HERMITE
#  [../]
  [./eta]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables]
  [./local_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[ICs]
#  [./cIC]
#    type = RandomIC
#    variable = c
#    min = -0.1
#    max =  0.1
#  [../]
  [./etaIC]
    type = RandomIC
    variable = eta
    min = -0.1
    max =  0.1
  [../]
[]

[Kernels]
  active = 'bulk interface dot'
#  [./bulk]
#    type = CahnHilliard
#    variable = c
#    f_name = fbulk
#    mob_name = M
#  [../]
  [./bulk]
    type = AllenCahn
    variable = eta
    f_name = fbulk
  [../]

#  [./interface]
#    type = CHInterface
#    variable = c
#    mob_name = M
#    kappa_name = kappa_c
#  [../]

  [./interface]
    type = ACInterface
    variable = eta
    kappa_name = kappa_eta
  [../]

#  [./dot]
#    type = TimeDerivative
#    variable = c
#  [../]

  [./dot]
    type = TimeDerivative
    variable = eta
  [../]

  # enable this kernel instead of 'bulk' to compare to CHMath
#  [./bulk_reference]
#    type = CHMath
#    variable = c
#    mob_name = M
#  [../]
[]

[AuxKernels]
#  [./local_energy]
#    type = TotalFreeEnergy
#    variable = local_energy
#    f_name = fbulk
#    interfacial_vars = c
#    kappa_names = kappa_c
#    execute_on = timestep_end
#  [../]

  [./local_energy]
    type = TotalFreeEnergy
    variable = local_energy
    f_name = fbulk
    interfacial_vars = eta
    kappa_names = kappa_eta
    execute_on = timestep_end
  [../]

[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]
#  [./mat]
#    type = GenericConstantMaterial
#    prop_names  = 'M   kappa_c'
#    prop_values = '1.0 0.5'
#    block = 0
#  [../]
  [./mat]
    type = GenericConstantMaterial
    prop_names  = 'L   kappa_eta'
    prop_values = '1.0 0.5'
    block = 0
  [../]
#  [./free_energy]
#    type = DerivativeParsedMaterial
#    block = 0
#    f_name = fbulk
#    args = c
#    constant_names = W
#    constant_expressions = 1.0/2^2
#    function = W*(1-c)^2*(1+c)^2
#    enable_jit = true
#  [../]
  [./free_energy]
    type = DerivativeParsedMaterial
    block = 0
    f_name = fbulk
    args = eta
    constant_names = W
    constant_expressions = 1.0/2^2
#    constant_expressions = -0.2
#    function = eta*(1-eta)*(eta-0.5+W)
    function = W*(1-eta)^2*(1+eta)^2
    enable_jit = true
  [../]

[]

[Postprocessors]
#  [./top]
#    type = SideIntegralVariablePostprocessor
#    variable = c
#    boundary = top
#  [../]
  [./top]
    type = SideIntegralVariablePostprocessor
    variable = eta
    boundary = top
  [../]
  [./total_free_energy]
    type = ElementIntegralVariablePostprocessor
    variable = local_energy
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  scheme = bdf2

  # Alternative preconditioning using the additive Schwartz method and LU decomposition
  #petsc_options_iname = '-pc_type -sub_ksp_type -sub_pc_type'
  #petsc_options_value = 'asm      preonly       lu          '

  # Preconditioning options using Hypre (algebraic multi-grid)
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre    boomeramg'

  l_max_its = 30
  l_tol = 1e-4
  nl_max_its = 20
  nl_rel_tol = 1e-9

  dt = 2.0
  end_time = 20.0
[]

[Outputs]
  exodus = true
  print_perf_log = true
[]
