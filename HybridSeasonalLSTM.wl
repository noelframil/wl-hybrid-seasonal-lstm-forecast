SeedRandom[2025];
regions = {"Galicia","Basque","Madrid","Catalonia","Valencia","Andalusia","Canary","Balearic"};
pos = <|"Galicia"->{-8.5,42.8},"Basque"->{-2.5,43.0},"Madrid"->{-3.7,40.4},"Catalonia"->{1.5,41.8},"Valencia"->{-0.4,39.5},"Andalusia"->{-4.5,37.5},"Canary"->{-15.5,28.3},"Balearic"->{3.0,39.6}|>;
edges = UndirectedEdge @@@ {{"Galicia","Madrid"},{"Basque","Madrid"},{"Madrid","Valencia"},{"Valencia","Catalonia"},{"Madrid","Andalusia"},{"Balearic","Valencia"}};
dates = DateRange[{2010,1},{2024,7},"Month"]; n = Length[dates]; t = Range[n];
x1 = Accumulate@RandomVariate[NormalDistribution[0,0.05], n]; x2 = Accumulate@RandomVariate[NormalDistribution[0,0.03], n];
x1 = (x1 - Mean[x1])/StandardDeviation[x1]; x2 = (x2 - Mean[x2])/StandardDeviation[x2];
amp = AssociationThread[regions -> RandomReal[{0.8,1.4}, Length[regions]]];
phi = AssociationThread[regions -> RandomReal[{0,2 Pi}, Length[regions]]];
eNoise[r_] := FoldList[#1*0.55 + #2 &, 0, RandomVariate[NormalDistribution[0,45], n]];
series = AssociationMap[
  With[{a = amp[#], p = phi[#], e = eNoise[#]},
    With[{y = Table[1200 + 220 t[[i]]/n + 180 a*Sin[2 Pi i/12 + p] + 60 x1[[i]] + 40 x2[[i]] + e[[i]], {i, n}]},
      TimeSeries[Transpose[{dates, y}]]
    ]
  ]&, regions
];
basis[i_] := {1., i, Cos[2 Pi i/12.], Sin[2 Pi i/12.], Cos[4 Pi i/12.], Sin[4 Pi i/12.]};
vars = Array[u, 6];
fit[r_] := Module[{y = Normal[series[r]]["Values"], lm},
  lm = LinearModelFit[Table[Append[basis[i], y[[i]]], {i, n}], vars, vars];
  <|"Model" -> lm, "Residuals" -> (y - Table[lm[basis[i]], {i, n}])|>
];
fits = AssociationMap[fit, regions];
seqLen = 12;
makePairs[v_] := Table[{Map[List, v[[i - seqLen + 1 ;; i]]], v[[i + 1]]}, {i, seqLen, Length[v] - 1}];
train = Flatten[Table[makePairs[fits[r]["Residuals"]], {r, regions}], 1];
net = NetChain[{LongShortTermMemoryLayer[32], LinearLayer[1]}, "Input" -> {"Varying", 1}, "Output" -> "Real"];
trained = NetTrain[net, train, MaxTrainingRounds -> 120, BatchSize -> 64, Method -> "ADAM", ValidationSet -> Scaled[0.1]];
ResidualForecast[v_, h_] := Module[{x = v[[-seqLen ;;]], p, out = {}}, Do[p = trained[Map[List, x]]; out = Append[out, p]; x = Rest@Append[x, p], {h}]; out];
h = 12;
baselineF[r_] := Table[fits[r]["Model"][basis[n + i]], {i, h}];
resF[r_] := ResidualForecast[fits[r]["Residuals"], h];
forecast = AssociationMap[baselineF[#] + resF[#] &, regions];
history = AssociationMap[Normal[series[#]]["Values"] &, regions];
bands[r_] := Module[{s = StandardDeviation[fits[r]["Residuals"]]}, {forecast[r] - 1.28 s, forecast[r] + 1.28 s, forecast[r] - 1.96 s, forecast[r] + 1.96 s}];
vmin = Min[Flatten[Values[forecast]]]; vmax = Max[Flatten[Values[forecast]]];
scaleVal[x_] := Rescale[x, {vmin, vmax}];
graphFor[m_] := Module[{vals = AssociationThread[regions -> ((forecast[#][[m]]) & /@ regions)]},
  Graph[regions, edges,
    VertexCoordinates -> pos,
    VertexLabels -> Placed["Name", Above],
    VertexSize -> AssociationMap[Scaled[.02 + .12*scaleVal[vals[#]]] &, regions],
    VertexStyle -> AssociationMap[ColorData["ThermometerColors"][scaleVal[vals[#]]] &, regions],
    ImageSize -> 600, PlotTheme -> "Minimal"]
];
plotFor[r_, m_] := Module[{y = history[r], f = forecast[r], b = bands[r]},
  Show[
    ListLinePlot[{y}, PlotRange -> All, ImageSize -> 600, PlotLegends -> {"History"}],
    ListLinePlot[{Join[{y[[-1]]}, f]}, PlotStyle -> Thick, PlotRange -> All, PlotLegends -> {"Forecast"}],
    ListLinePlot[{Join[{y[[-1]]}, b[[1]]]}, PlotStyle -> Directive[Opacity[.3]], Filling -> {{1} -> {{2}, Opacity[.15]}}],
    ListLinePlot[{Join[{y[[-1]]}, b[[2]]]}, PlotStyle -> Directive[Opacity[.3]]],
    ListLinePlot[{Join[{y[[-1]]}, b[[3]]]}, PlotStyle -> Directive[Opacity[.15]]],
    ListLinePlot[{Join[{y[[-1]]}, b[[4]]]}, PlotStyle -> Directive[Opacity[.15]]]
  ]
];
Manipulate[
  Column[{Style["Hybrid Seasonal–Trend + LSTM Residual Forecast", 14, Bold], graphFor[m], plotFor[reg, m]}],
  {{m, 1, "Forecast Month"}, 1, h, 1, Appearance -> "Labeled"},
  {{reg, "Madrid", "Region"}, regions}
]