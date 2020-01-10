within IBPSA.Fluid.Actuators.BaseClasses;
partial model PartialDamperExponential
  "Partial model for air dampers with exponential opening characteristics"
  extends IBPSA.Fluid.BaseClasses.PartialResistance(
    final dp_nominal=dpDamper_nominal+dpFixed_nominal,
    m_flow_turbulent=if use_deltaM then deltaM * m_flow_nominal else
      eta_default*ReC*sqrt(A)*facRouDuc);
  extends IBPSA.Fluid.Actuators.BaseClasses.ActuatorSignal;
  parameter Modelica.SIunits.PressureDifference dpDamper_nominal(displayUnit="Pa")
    "Pressure drop of fully open damper at nominal mass flow rate"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.PressureDifference dpFixed_nominal(displayUnit="Pa") = 0
    "Pressure drop of duct and resistances other than the damper in series, at nominal mass flow rate"
    annotation(Dialog(group = "Nominal condition"));
  parameter Boolean use_deltaM = true
    "Set to true to use deltaM for turbulent transition, else ReC is used";
  parameter Real deltaM = 0.3
    "Fraction of nominal mass flow rate where transition to turbulent occurs"
    annotation(Dialog(enable=use_deltaM));
  final parameter Modelica.SIunits.Velocity v_nominal=
    (2 / rho_default / k1 * dpDamper_nominal)^0.5
    "Nominal face velocity";
  final parameter Modelica.SIunits.Area A=m_flow_nominal/rho_default/v_nominal
    "Face area";
  parameter Boolean roundDuct = false
    "Set to true for round duct, false for square cross section"
    annotation(Dialog(enable=not use_deltaM));
  parameter Real ReC=4000 "Reynolds number where transition to turbulent starts"
    annotation(Dialog(enable=not use_deltaM));
  parameter Real a(unit="1")=-1.51 "Coefficient a for damper characteristics"
    annotation(Dialog(tab="Damper coefficients"));
  parameter Real b(unit="1")=0.105*90 "Coefficient b for damper characteristics"
    annotation(Dialog(tab="Damper coefficients"));
  parameter Real yL(unit="1") = 15/90 "Lower value for damper curve"
    annotation(Dialog(tab="Damper coefficients"));
  parameter Real yU(unit="1") = 55/90 "Upper value for damper curve"
    annotation(Dialog(tab="Damper coefficients"));
  final parameter Real k0(min=0, unit="1") = 2 * rho_default * (A / (l * kDamMax))^2
    "Loss coefficient for y=0, k0 = pressure drop divided by dynamic pressure"
    annotation(Dialog(tab="Damper coefficients"));
  parameter Real k1(min=0, unit="1") = 0.45
    "Loss coefficient for y=1, k1 = pressure drop divided by dynamic pressure"
    annotation(Dialog(tab="Damper coefficients"));
  parameter Real l(min=1e-10, max=1) = 0.0001
    "Damper leakage, ratio of flow coefficients k(y=0)/k(y=1)"
    annotation(Dialog(tab="Damper coefficients"));
  parameter Boolean use_constant_density=true
    "Set to true to use constant density for flow friction"
    annotation (Evaluate=true, Dialog(tab="Advanced"));
  Medium.Density rho "Medium density";
  final parameter Real kFixed(fixed=false)
    "Flow coefficient of fixed resistance that may be in series with damper, k=m_flow/sqrt(dp), with unit=(kg.m)^(1/2).";
  Real kDam
    "Flow coefficient of damper, k=m_flow/sqrt(dp), with unit=(kg.m)^(1/2)";
  Real k
    "Flow coefficient of damper plus fixed resistance, k=m_flow/sqrt(dp), with unit=(kg.m)^(1/2)";
protected
  parameter Medium.Density rho_default=Medium.density(sta_default)
    "Density, used to compute fluid volume";
  parameter Real facRouDuc= if roundDuct then sqrt(Modelica.Constants.pi)/2 else 1;
  parameter Real kL = IBPSA.Fluid.Actuators.BaseClasses.exponentialDamper(
    y=yL, a=a, b=b, cL=cL, cU=cU, yL=yL, yU=yU)^2
    "Loss coefficient at the lower limit of the exponential characteristics";
  parameter Real kU = IBPSA.Fluid.Actuators.BaseClasses.exponentialDamper(
    y=yU, a=a, b=b, cL=cL, cU=cU, yL=yL, yU=yU)^2
    "Loss coefficient at the upper limit of the exponential characteristics";
  parameter Real[3] cL={
    (Modelica.Math.log(k0) - b - a)/yL^2,
    (-b*yL - 2*Modelica.Math.log(k0) + 2*b + 2*a)/yL,
    Modelica.Math.log(k0)} "Polynomial coefficients for curve fit for y < yl";
  parameter Real[3] cU={
    (Modelica.Math.log(k1) - a)/(yU^2 - 2*yU + 1),
    (-b*yU^2 - 2*Modelica.Math.log(k1)*yU - (-2*b - 2*a)*yU - b)/(yU^2 - 2*yU + 1),
    (Modelica.Math.log(k1)*yU^2 + b*yU^2 + (-2*b - 2*a)*yU + b + a)/(yU^2 - 2*yU + 1)}
    "Polynomial coefficients for curve fit for y > yu";
  parameter Real kDamMax =  (2 * rho_default / k1)^0.5 * A
    "Flow coefficient of damper fully open, k=m_flow/sqrt(dp), with unit=(kg.m)^(1/2)";
  parameter Real kTotMax = if dpFixed_nominal > Modelica.Constants.eps then
    sqrt(1 / (1 / kFixed^2 + 1 / kDamMax^2)) else kDamMax
    "Flow coefficient of damper fully open plus fixed resistance, with unit=(kg.m)^(1/2)";
  parameter Real kDamMin = (2 * rho_default / k0)^0.5 * A
    "Flow coefficient of damper fully closed, with unit=(kg.m)^(1/2)";
  parameter Real kTotMin = if dpFixed_nominal > Modelica.Constants.eps then
    sqrt(1 / (1 / kFixed^2 + 1 / kDamMin^2)) else kDamMin
    "Flow coefficient of damper fully closed + fixed resistance, with unit=(kg.m)^(1/2)";
initial equation
  assert(dpDamper_nominal > Modelica.Constants.eps,
    "In " + getInstanceName() + ": dpDamper_nominal must be strictly greater than zero.");
  assert(dpFixed_nominal >= 0,
    "In " + getInstanceName() + ": dpFixed_nominal must be greater than zero.");
  assert(yL < yU,
    "In " + getInstanceName() + ": yL must be strictly lower than yU.");
  assert(m_flow_turbulent > 0,
    "In " + getInstanceName() + ": m_flow_turbulent must be strictly greater than zero.");
  assert(k1 >= 0.2,
    "In " + getInstanceName() + ": k1 must be greater than 0.2. k1=" + String(k1));
  assert(k1 < kU,
    "In " + getInstanceName() + ": k1 must be strictly lower than exp(a + b * (1 - yU)). k1=" +
    String(k1) + ", exp(...) = " + String(kU));
  assert(k0 <= 1e10,
    "In " + getInstanceName() + ": k0 must be lower than 1e10. k0=" + String(k0));
  assert(k0 > kL,
    "In " + getInstanceName() + ": k0 must be strictly higher than exp(a + b * (1 - yL)). k0=" +
    String(k0) + ", exp(...) = " + String(kL));
  kFixed = if dpFixed_nominal > Modelica.Constants.eps then
    m_flow_nominal / sqrt(dpFixed_nominal) else Modelica.Constants.inf;
equation
  rho = if use_constant_density then
      rho_default
    else
      Medium.density(Medium.setState_phX(
        port_a.p, inStream(port_a.h_outflow), inStream(port_a.Xi_outflow)));
  // flow coefficient, k = m_flow/sqrt(dp)
  kDam=sqrt(2*rho)*A/IBPSA.Fluid.Actuators.BaseClasses.exponentialDamper(
    y=y_actual,
    a=a,
    b=b,
    cL=cL,
    cU=cU,
    yL=yL,
    yU=yU);
  k = if dpFixed_nominal > Modelica.Constants.eps then sqrt(1/(1/kFixed^2 + 1/kDam^2)) else kDam;
annotation(Documentation(info="<html>
<p>
Partial model for air dampers with exponential opening characteristics.
This is the base model for air dampers.
The model implements the functions that relate the opening signal and the
flow coefficient.
The model also defines parameters that are used by different air damper
models.
</p>
<p>
For a description of the opening characteristics and typical parameter values,
see the damper model
<a href=\"modelica://IBPSA.Fluid.Actuators.Dampers.Exponential\">
IBPSA.Fluid.Actuators.Dampers.Exponential</a>.
</p>
</html>",
revisions="<html>
<ul>
<li>
December 23, 2019, by Antoine Gautier:<br/>
Removed the equations involving <code>m_flow</code> and <code>dp</code> that now need
to be added in each derived damper model.<br/>
Added the declaration of <code>dpDamper_nominal</code> and <code>dpFixed_nominal</code>.<br/>
Replaced <code>k0</code> by leakage coefficient.<br/>
Modified the limiting values for <code>k0</code> and <code>k1</code>.<br/>
This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/1188\">#1188</a>.
</li>
<li>
March 22, 2017, by Michael Wetter:<br/>
Added back <code>v_nominal</code>, but set the assignment of <code>A</code>
to be final. This allows scaling the model with <code>m_flow_nominal</code>,
which is generally known in the flow leg,
and <code>v_nominal</code>, for which a default value can be specified.<br/>
This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/544\">#544</a>.
</li>
<li>
October 12, 2016 by David Blum:<br/>
Removed parameter <code>v_nominal</code> and variable <code>area</code>,
to simplify parameterization of the model.
Also added assertion statements upon initialization
for parameters <code>k0</code> and <code>k1</code> so that they fall within
suggested ranges found in ASHRAE 825-RP. This is for
<a href=\"https://github.com/ibpsa/modelica-ibpsa/issues/544\">#544</a>.
</li>
<li>
January 27, 2015 by Michael Wetter:<br/>
Set <code>Evaluate=true</code> for <code>use_constant_density</code>.
This is a structural parameter. Adding this annotation leads to fewer
numerical Jacobians for
<code>Buildings.Examples.VAVReheat.ClosedLoop</code>
with
<code>Buildings.Media.PerfectGases.MoistAirUnsaturated</code>.
</li>
<li>
December 14, 2012 by Michael Wetter:<br/>
Renamed protected parameters for consistency with the naming conventions.
</li>
<li>
January 16, 2012 by Michael Wetter:<br/>
To simplify object inheritance tree, revised base classes
<code>IBPSA.Fluid.BaseClasses.PartialResistance</code>,
<code>IBPSA.Fluid.Actuators.BaseClasses.PartialTwoWayValve</code>,
<code>IBPSA.Fluid.Actuators.BaseClasses.PartialDamperExponential</code>,
<code>IBPSA.Fluid.Actuators.BaseClasses.PartialActuator</code>
and model
<code>IBPSA.Fluid.FixedResistances.PressureDrop</code>.
</li>
<li>
August 5, 2011, by Michael Wetter:<br/>
Moved linearized pressure drop equation from the function body to the equation
section. With the previous implementation,
the symbolic processor may not rearrange the equations, which can lead
to coupled equations instead of an explicit solution.
</li>
<li>
June 22, 2008 by Michael Wetter:<br/>
Extended range of control signal from 0 to 1 by implementing the function
<a href=\"modelica://IBPSA.Fluid.Actuators.BaseClasses.exponentialDamper\">
exponentialDamper</a>.
</li>
<li>
June 10, 2008 by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
   Icon(graphics={Line(
         points={{0,100},{0,-24}}),
        Rectangle(
          extent={{-100,40},{100,-42}},
          lineColor={0,0,0},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={192,192,192}),
        Rectangle(
          extent={{-100,22},{100,-24}},
          lineColor={0,0,0},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={0,127,255})}));
end PartialDamperExponential;
