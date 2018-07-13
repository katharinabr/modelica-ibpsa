within IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Data.ConfigurationData;
record SandBox_validation
  "ConfigurationData record for the Beier et al. (2011) experiment"
  extends IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Data.ConfigurationData.Template(
    borCon = Types.BoreholeConfiguration.SingleUTube,
    use_Rb=true,
    Rb=0.165,
    nbBor=1,
    cooBor={{0,0}},
    mBor_flow_nominal=0.197/998*1000,
    dp_nominal=5e4,
    hBor=18.3,
    rBor=0.063,
    dBor=0.0,
    rTub=0.02733/2,
    kTub=0.39,
    eTub=0.003,
    xC=0.053/2);

  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram( coordinateSystem(preserveAspectRatio=false)),
    Documentation(
info="<html>
<p>This record contains the configuration data of the Beier et al.
(2011) experiment.</p>
<h4>References</h4>
<p>
Beier, R.A., Smith, M.D. and Spitler, J.D. 2011. <i>Reference data sets for
vertical borehole ground heat exchanger models and thermal response test
analysis</i>. Geothermics 40: 79-85.
</p>
</html>",
revisions="<html>
<ul>
<li>
July 28, 2018, by Damien Picard:<br/>
First implementation.
</li>
</ul>
</html>"));
end SandBox_validation;
