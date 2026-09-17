% MATLAB Implementation of the Zukowski ECM-ROS Model

function zukowskiECMROS()

%% =========================================================
%  PARAMETERS
%% =========================================================

CL        = 1000;       % pacing cycle length (ms)
ft        = 10 * CL;    % final time (ms)
skip      = 1;          % number of timesteps to skip in output sampling
beatssave = 2;          % number of beats to save in output

amp      = -80;         % stimulus amplitude (uA/uF)
start    = 100;         % stimulus start time relative to each beat (ms)
duration = 0.5;         % stimulus duration (ms)

celltype = 0;           % endo=0, epi=1, M=2

%% =========================================================
%  CONSTANTS
%% =========================================================

nao = 140.0;    % extracellular sodium (mM)
cao = 1.8;      % extracellular calcium (mM)
ko  = 5.4;      % extracellular potassium (mM)

% Buffer parameters
BSRmax  = 0.047;
KmBSR   = 0.00087;
BSLmax  = 1.124;
KmBSL   = 0.0087;
cmdnmax = 0.05;
kmcmdn  = 0.00238;
trpnmax = 0.07;
kmtrpn  = 0.0005;
csqnmax = 10.0;
kmcsqn  = 0.8;

% CaMK parameters
aCaMK  = 0.05;
bCaMK  = 0.00068;
CaMKo  = 0.05;
KmCaM  = 0.0015;
KmCaMK = 0.15;

% Physical constants
R = 8314.0;
T = 310.0;
F = 96485.0;

% Cell geometry
L_cell  = 0.01;
rad     = 0.0011;
vcell   = 1000 * pi * rad^2 * L_cell;
Ageo    = 2 * pi * rad^2 + 2 * pi * rad * L_cell;
Acap    = 2 * Ageo;
vmyo    = 0.68   * vcell;
vmito   = 0.26   * vcell;
vsr     = 0.06   * vcell;
vnsr    = 0.0552 * vcell;
vjsr    = 0.0048 * vcell;
vss     = 0.02   * vcell;

% Mito/ROS constants
ATP     = 7.7107;
ADP     = 0.2893;
ETC_Leak = 0.4;

%% =========================================================
%  INITIAL CONDITIONS (1Hz Pacing ETCLeak = 0.4)
%% =========================================================

v      = -87.4851;
nai    = 7.47971;
nass   = 7.47991;
ki     = 143.228;
kss    = 143.228;
cai    = 0.00015508;
cass   = 0.000149225;
cansr  = 1.71704;
cajsr  = 1.58954;
m      = 0.00773583;
hf     = 0.679915;
hs     = 0.679897;
j_gate = 0.679806;
hsp    = 0.433986;
jp     = 0.679754;
mL     = 0.000207679;
hL     = 0.477363;
hLp    = 0.248613;
a      = 0.00103659;
iF     = 0.999512;
iS     = 0.528323;
ap     = 0.000528179;
iFp    = 0.999512;
iSp    = 0.577794;
d      = 2.64499e-09;
ff     = 1;
fs     = 0.89364;
fcaf   = 1;
fcas   = 0.999425;
jca    = 0.999885;
nca    = 0.0227253;
ffp    = 1;
fcafp  = 1;
xrf    = 9.48683e-06;
xrs    = 0.511752;
xs1    = 0.306619;
xs2    = 0.000204332;
xk1    = 0.996893;
Jrelnp = 2.88142e-07;
Jrelp  = 3.59715e-07;
CaMKt  = 0.0146446;

Psi   = 189.09;
ATPm  = 0.740296;
ADPm  = 9.25968;
Cam   = 0.000165787;
NADHm = 2.69638;
ROSm  = 7.65106e-07;
ROSi  = 3.58658e-05;
H2O2  = 1.03169e-05;
GSH   = 0.911154;

%% =========================================================
%  TIMING & COUNTING VARIABLES
%% =========================================================

APD_flag  = 0;
APD       = 0;
t_vdot_max = 0;
vrest     = 0;
vo        = v;
dt        = 0.005;
t         = 0;
vdot_old  = 0;
vdot      = 0;
vdot_max  = 0;
p_beat    = 1;
n_beat    = 0;
counter   = 1;
Ist       = 0;

% Initialize currents/fluxes to avoid undefined variable errors
ENa = 0; EK = 0; EKs = 0;
INa = 0; INaL = 0; Ito = 0; ICaL = 0; ICaNa = 0; ICaK = 0;
IKr = 0; IKs = 0; IK1 = 0; INaCa_i = 0; INaCa_ss = 0; INaCa = 0;
INaK = 0; IKb = 0; INab = 0; IpCa = 0; ICab = 0;
Jrel = 0; Jup = 0; Jtr = 0; Jdiff = 0; JdiffNa = 0; JdiffK = 0; Jleak = 0;
CaMKa = 0; CaMKb = 0;
V_uni = 0; V_mNaCa = 0; J_mPTP = 0;
GNaL_factor = 1.0; pca_factor = 1.0;
Jrel_ROS = 1.0; Jup_ROS = 1.0;

%% =========================================================
%  OUTPUT FILE SETUP
%% =========================================================

fid1 = fopen('output3_1Hz.txt',      'w');

%% =========================================================
%  MAIN SIMULATION LOOP
%% =========================================================

while t <= ft

    % --- ROS-dependent scaling factors ---
    GNaL_factor = 1.0355 / (1.0 + exp(-9000.0 * (ROSi - 5.5e-4))) + 0.9823;
    pca_factor  = 3.1064 / (1.0 + exp(-9000.0 * (ROSi - 5.5e-4))) + 0.9468;
    Jrel_ROS    = 1.0 + (8.3 - 1.0) * (1.0 - exp(-27.01 * ROSi));
    Jup_ROS     = 1.02 * exp(-43.67 * ROSi);

    t = t + dt;

    % --- Reversal potentials ---
    ENa = (R*T/F) * log(nao / nai);
    EK  = (R*T/F) * log(ko  / ki);
    EKs = (R*T/F) * log((ko + 0.01833*nao) / (ki + 0.01833*nai));

    % --- Rates, Gates, Currents ---
    CaMKb = CaMKo * (1.0 - CaMKt) / (1.0 + KmCaM/cass);
    CaMKa = CaMKb + CaMKt;
    vffrt = v * F * F / (R * T);
    vfrt  = v * F / (R * T);

    % INa
    mss = 1.0 / (1.0 + exp((-(v+39.57))/9.871));
    tm  = 1.0 / (6.765*exp((v+11.64)/34.77) + 8.552*exp(-(v+77.42)/5.955));
    m   = mss - (mss - m) * exp(-dt/tm);

    hss = 1.0 / (1 + exp((v+82.90)/6.086));
    thf = 1.0 / (1.432e-5*exp(-(v+1.196)/6.285) + 6.149*exp((v+0.5096)/20.27));
    ths = 1.0 / (0.009794*exp(-(v+17.95)/28.05) + 0.3343*exp((v+5.730)/56.66));
    Ahf = 0.99;
    Ahs = 1.0 - Ahf;
    hf  = hss - (hss - hf) * exp(-dt/thf);
    hs  = hss - (hss - hs) * exp(-dt/ths);
    h   = Ahf*hf + Ahs*hs;

    jss = hss;
    tj  = 2.038 + 1.0/(0.02136*exp(-(v+100.6)/8.281) + 0.3052*exp((v+0.9941)/38.45));
    j_gate = jss - (jss - j_gate) * exp(-dt/tj);

    hssp = 1.0 / (1 + exp((v+89.1)/6.086));
    thsp = 3.0 * ths;
    hsp  = hssp - (hssp - hsp) * exp(-dt/thsp);
    hp   = Ahf*hf + Ahs*hsp;

    tjp    = 1.46 * tj;
    jp     = jss - (jss - jp) * exp(-dt/tjp);
    GNa    = 75;
    fINap  = 1.0 / (1.0 + KmCaMK/CaMKa);
    INa    = GNa * (v-ENa) * m^3 * ((1.0-fINap)*h*j_gate + fINap*hp*jp);

    % INaL
    mLss   = 1.0 / (1.0 + exp((-(v+42.85))/5.264));
    tmL    = tm;
    mL     = mLss - (mLss - mL) * exp(-dt/tmL);
    hLss   = 1.0 / (1.0 + exp((v+87.61)/7.488));
    thL    = 200.0;
    hL     = hLss - (hLss - hL) * exp(-dt/thL);
    hLssp  = 1.0 / (1.0 + exp((v+93.81)/7.488));
    thLp   = 3.0 * thL;
    hLp    = hLssp - (hLssp - hLp) * exp(-dt/thLp);
    GNaL   = 0.0075 * GNaL_factor;
    if celltype == 1
        GNaL = GNaL * 0.6;
    end
    fINaLp = 1.0 / (1.0 + KmCaMK/CaMKa);
    INaL   = GNaL * (v-ENa) * mL * ((1.0-fINaLp)*hL + fINaLp*hLp);

    % Ito
    ass  = 1.0 / (1.0 + exp((-(v-14.34))/14.82));
    ta   = 1.0515 / (1.0/(1.2089*(1.0+exp(-(v-18.4099)/29.3814))) + 3.5/(1.0+exp((v+100.0)/29.3814)));
    a    = ass - (ass - a) * exp(-dt/ta);
    iss  = 1.0 / (1.0 + exp((v+43.94)/5.711));
    if celltype == 1
        delta_epi = 1.0 - (0.95/(1.0+exp((v+70.0)/5.0)));
    else
        delta_epi = 1.0;
    end
    tiF = 4.562 + 1/(0.3933*exp((-(v+100.0))/100.0) + 0.08004*exp((v+50.0)/16.59));
    tiS = 23.62 + 1/(0.001416*exp((-(v+96.52))/59.05) + 1.780e-8*exp((v+114.1)/8.079));
    tiF = tiF * delta_epi;
    tiS = tiS * delta_epi;
    AiF = 1.0 / (1.0 + exp((v-213.6)/151.2));
    AiS = 1.0 - AiF;
    iF  = iss - (iss - iF) * exp(-dt/tiF);
    iS  = iss - (iss - iS) * exp(-dt/tiS);
    i_gate = AiF*iF + AiS*iS;

    assp = 1.0 / (1.0 + exp((-(v-24.34))/14.82));
    ap   = assp - (assp - ap) * exp(-dt/ta);
    dti_develop = 1.354 + 1.0e-4/(exp((v-167.4)/15.89) + exp(-(v-12.23)/0.2154));
    dti_recover = 1.0 - 0.5/(1.0 + exp((v+70.0)/20.0));
    tiFp = dti_develop * dti_recover * tiF;
    tiSp = dti_develop * dti_recover * tiS;
    iFp  = iss - (iss - iFp) * exp(-dt/tiFp);
    iSp  = iss - (iss - iSp) * exp(-dt/tiSp);
    ip   = AiF*iFp + AiS*iSp;

    Gto = 0.02;
    if celltype == 1, Gto = Gto * 4.0; end
    if celltype == 2, Gto = Gto * 4.0; end
    fItop = 1.0 / (1.0 + KmCaMK/CaMKa);
    Ito   = Gto * (v-EK) * ((1.0-fItop)*a*i_gate + fItop*ap*ip);

    % ICaL
    dss    = 1.0 / (1.0 + exp((-(v+3.940))/4.230));
    td     = 0.6 + 1.0/(exp(-0.05*(v+6.0)) + exp(0.09*(v+14.0)));
    d      = dss - (dss - d) * exp(-dt/td);
    fss    = 1.0 / (1.0 + exp((v+19.58)/3.696));
    tff    = 7.0 + 1.0/(0.0045*exp(-(v+20.0)/10.0) + 0.0045*exp((v+20.0)/10.0));
    tfs    = 1000.0 + 1.0/(0.000035*exp(-(v+5.0)/4.0) + 0.000035*exp((v+5.0)/6.0));
    Aff    = 0.6;
    Afs    = 1.0 - Aff;
    ff     = fss - (fss - ff) * exp(-dt/tff);
    fs     = fss - (fss - fs) * exp(-dt/tfs);
    f_gate = Aff*ff + Afs*fs;

    fcass  = fss;
    tfcaf  = 7.0 + 1.0/(0.04*exp(-(v-4.0)/7.0) + 0.04*exp((v-4.0)/7.0));
    tfcas  = 100.0 + 1.0/(0.00012*exp(-v/3.0) + 0.00012*exp(v/7.0));
    Afcaf  = 0.3 + 0.6/(1.0 + exp((v-10.0)/10.0));
    Afcas  = 1.0 - Afcaf;
    fcaf   = fcass - (fcass - fcaf) * exp(-dt/tfcaf);
    fcas   = fcass - (fcass - fcas) * exp(-dt/tfcas);
    fca    = Afcaf*fcaf + Afcas*fcas;

    tjca   = 75.0;
    jca    = fcass - (fcass - jca) * exp(-dt/tjca);
    tffp   = 2.5 * tff;
    ffp    = fss - (fss - ffp) * exp(-dt/tffp);
    fp     = Aff*ffp + Afs*fs;
    tfcafp = 2.5 * tfcaf;
    fcafp  = fcass - (fcass - fcafp) * exp(-dt/tfcafp);
    fcap   = Afcaf*fcafp + Afcas*fcas;

    Kmn   = 0.002;
    k2n   = 1000.0;
    km2n  = jca * 1.0;
    anca  = 1.0 / (k2n/km2n + (1.0 + Kmn/cass)^4);
    nca   = anca*k2n/km2n - (anca*k2n/km2n - nca) * exp(-km2n*dt);

    PhiCaL  = 4.0*vffrt*(cass*exp(2.0*vfrt) - 0.341*cao) / (exp(2.0*vfrt) - 1.0);
    PhiCaNa = 1.0*vffrt*(0.75*nass*exp(1.0*vfrt) - 0.75*nao) / (exp(1.0*vfrt) - 1.0);
    PhiCaK  = 1.0*vffrt*(0.75*kss*exp(1.0*vfrt) - 0.75*ko)   / (exp(1.0*vfrt) - 1.0);

    PCa = 0.0001;
    if celltype == 1, PCa = PCa * 1.2; end
    if celltype == 2, PCa = PCa * 2.5; end
    PCap   = (1.1 * PCa)* pca_factor;
    PCaNa  = 0.00125 * PCa;
    PCaK   = 3.574e-4 * PCa;
    PCaNap = 0.00125 * PCap;
    PCaKp  = 3.574e-4 * PCap;
    fICaLp = 1.0 / (1.0 + KmCaMK/CaMKa);

    ICaL  = (1.0-fICaLp)*PCa *PhiCaL *d*(f_gate*(1.0-nca)+jca*fca*nca)  + fICaLp*PCap *PhiCaL *d*(fp*(1.0-nca)+jca*fcap*nca);
    ICaNa = (1.0-fICaLp)*PCaNa*PhiCaNa*d*(f_gate*(1.0-nca)+jca*fca*nca) + fICaLp*PCaNap*PhiCaNa*d*(fp*(1.0-nca)+jca*fcap*nca);
    ICaK  = (1.0-fICaLp)*PCaK*PhiCaK*d*(f_gate*(1.0-nca)+jca*fca*nca)  + fICaLp*PCaKp*PhiCaK*d*(fp*(1.0-nca)+jca*fcap*nca);

    % IKr
    xrss  = 1.0 / (1.0 + exp((-(v+8.337))/6.789));
    txrf  = 12.98 + 1.0/(0.3652*exp((v-31.66)/3.869)  + 4.123e-5*exp((-(v-47.78))/20.38));
    txrs  = 1.865 + 1.0/(0.06629*exp((v-34.70)/7.355) + 1.128e-5*exp((-(v-29.74))/25.94));
    Axrf  = 1.0 / (1.0 + exp((v+54.81)/38.21));
    Axrs  = 1.0 - Axrf;
    xrf   = xrss - (xrss - xrf) * exp(-dt/txrf);
    xrs   = xrss - (xrss - xrs) * exp(-dt/txrs);
    xr    = Axrf*xrf + Axrs*xrs;
    rkr   = 1.0/(1.0+exp((v+55.0)/75.0)) * 1.0/(1.0+exp((v-10.0)/30.0));
    GKr   = 0.046;
    if celltype == 1, GKr = GKr * 1.3; end
    if celltype == 2, GKr = GKr * 0.8; end
    IKr   = GKr * sqrt(ko/5.4) * xr * rkr * (v - EK);

    % IKs
    xs1ss  = 1.0 / (1.0 + exp((-(v+11.60))/8.932));
    txs1   = 817.3 + 1.0/(2.326e-4*exp((v+48.28)/17.80) + 0.001292*exp((-(v+210.0))/230.0));
    xs1    = xs1ss - (xs1ss - xs1) * exp(-dt/txs1);
    xs2ss  = xs1ss;
    txs2   = 1.0/(0.01*exp((v-50.0)/20.0) + 0.0193*exp((-(v+66.54))/31.0));
    xs2    = xs2ss - (xs2ss - xs2) * exp(-dt/txs2);
    KsCa   = 1.0 + 0.6/(1.0 + (3.8e-5/cai)^1.4);
    GKs    = 0.0034;
    if celltype == 1, GKs = GKs * 1.4; end
    IKs    = GKs * KsCa * xs1 * xs2 * (v - EKs);

    % IK1
    xk1ss  = 1.0 / (1.0 + exp(-(v + 2.5538*ko + 144.59)/(1.5692*ko + 3.8115)));
    txk1   = 122.2 / (exp((-(v+127.2))/20.36) + exp((v+236.8)/69.33));
    xk1    = xk1ss - (xk1ss - xk1) * exp(-dt/txk1);
    rk1    = 1.0 / (1.0 + exp((v + 105.8 - 2.6*ko)/9.493));
    GK1    = 0.1908;
    if celltype == 1, GK1 = GK1 * 1.2; end
    if celltype == 2, GK1 = GK1 * 1.3; end
    IK1    = GK1 * sqrt(ko) * rk1 * xk1 * (v - EK);

    % INaCa_i
    kna1   = 15.0;  kna2 = 5.0;  kna3 = 88.12;
    kasymm = 12.5;
    wna    = 6.0e4; wca = 6.0e4; wnaca = 5.0e3;
    kcaon  = 1.5e6; kcaoff = 5.0e3;
    qna    = 0.5224; qca = 0.1670;
    hca    = exp((qca*v*F)/(R*T));
    hna    = exp((qna*v*F)/(R*T));

    h1  = 1 + nai/kna3*(1+hna);
    h2  = (nai*hna)/(kna3*h1);
    h3  = 1.0/h1;
    h4  = 1.0 + nai/kna1*(1+nai/kna2);
    h5  = nai^2/(h4*kna1*kna2);
    h6  = 1.0/h4;
    h7  = 1.0 + nao/kna3*(1.0+1.0/hna);
    h8  = nao/(kna3*hna*h7);
    h9  = 1.0/h7;
    h10 = kasymm + 1.0 + nao/kna1*(1.0+nao/kna2);
    h11 = nao^2/(h10*kna1*kna2);
    h12 = 1.0/h10;

    k1_  = h12*cao*kcaon;
    k2_  = kcaoff;
    k3p_ = h9*wca;
    k3pp_= h8*wnaca;
    k3_  = k3p_ + k3pp_;
    k4p_ = h3*wca/hca;
    k4pp_= h2*wnaca;
    k4_  = k4p_ + k4pp_;
    k5_  = kcaoff;
    k6_  = h6*cai*kcaon;
    k7_  = h5*h2*wna;
    k8_  = h8*h11*wna;

    x1_  = k2_*k4_*(k7_+k6_) + k5_*k7_*(k2_+k3_);
    x2_  = k1_*k7_*(k4_+k5_) + k4_*k6_*(k1_+k8_);
    x3_  = k1_*k3_*(k7_+k6_) + k8_*k6_*(k2_+k3_);
    x4_  = k2_*k8_*(k4_+k5_) + k3_*k5_*(k1_+k8_);
    denom_ = x1_+x2_+x3_+x4_;
    E1_  = x1_/denom_;
    E2_  = x2_/denom_;
    E3_  = x3_/denom_;
    E4_  = x4_/denom_;

    KmCaAct = 150.0e-6;
    allo    = 1.0 / (1.0 + (KmCaAct/cai)^2);
    zna     = 1.0;
    zca     = 2.0;
    JncxNa  = 3.0*(E4_*k7_ - E1_*k8_) + E3_*k4pp_ - E2_*k3pp_;
    JncxCa  = E2_*k2_ - E1_*k1_;
    Gncx    = 0.0008;
    if celltype == 1, Gncx = Gncx * 1.1; end
    if celltype == 2, Gncx = Gncx * 1.4; end
    INaCa_i = 0.8 * Gncx * allo * (zna*JncxNa + zca*JncxCa);

    % INaCa_ss (same but with nass, cass)
    h1  = 1 + nass/kna3*(1+hna);
    h2  = (nass*hna)/(kna3*h1);
    h3  = 1.0/h1;
    h4  = 1.0 + nass/kna1*(1+nass/kna2);
    h5  = nass^2/(h4*kna1*kna2);
    h6  = 1.0/h4;
    % h7..h12 unchanged from above

    k1_  = h12*cao*kcaon;
    k2_  = kcaoff;
    k3p_ = h9*wca;
    k3pp_= h8*wnaca;
    k3_  = k3p_ + k3pp_;
    k4p_ = h3*wca/hca;
    k4pp_= h2*wnaca;
    k4_  = k4p_ + k4pp_;
    k5_  = kcaoff;
    k6_  = h6*cass*kcaon;
    k7_  = h5*h2*wna;
    k8_  = h8*h11*wna;

    x1_  = k2_*k4_*(k7_+k6_) + k5_*k7_*(k2_+k3_);
    x2_  = k1_*k7_*(k4_+k5_) + k4_*k6_*(k1_+k8_);
    x3_  = k1_*k3_*(k7_+k6_) + k8_*k6_*(k2_+k3_);
    x4_  = k2_*k8_*(k4_+k5_) + k3_*k5_*(k1_+k8_);
    denom_ = x1_+x2_+x3_+x4_;
    E1_  = x1_/denom_;
    E2_  = x2_/denom_;
    E3_  = x3_/denom_;
    E4_  = x4_/denom_;

    allo    = 1.0 / (1.0 + (KmCaAct/cass)^2);
    JncxNa  = 3.0*(E4_*k7_ - E1_*k8_) + E3_*k4pp_ - E2_*k3pp_;
    JncxCa  = E2_*k2_ - E1_*k1_;
    INaCa_ss= 0.2 * Gncx * allo * (zna*JncxNa + zca*JncxCa);
    INaCa   = INaCa_i + INaCa_ss;

    % INaK
    k1p_  = 949.5;  k1m_ = 182.4;
    k2p_  = 687.2;  k2m_ = 39.4;
    k3p_  = 1899.0; k3m_ = 79300.0;
    k4p_  = 639.0;  k4m_ = 40.0;
    Knai0 = 9.073;  Knao0 = 27.78;
    delta_nak = -0.1550;
    Knai  = Knai0 * exp((delta_nak*v*F)/(3.0*R*T));
    Knao  = Knao0 * exp(((1.0-delta_nak)*v*F)/(3.0*R*T));
    Kki   = 0.5;    Kko = 0.3582;
    MgADP = 0.05;   MgATP = 9.8;
    Kmgatp= 1.698e-7;
    H_ion = 1.0e-7;
    eP    = 4.2;
    Khp   = 1.698e-7;
    Knap  = 224.0;  Kxkur = 292.0;
    P_nak = eP / (1.0 + H_ion/Khp + nai/Knap + ki/Kxkur);

    a1_   = (k1p_*(nai/Knai)^3) / ((1.0+nai/Knai)^3 + (1.0+ki/Kki)^2 - 1.0);
    b1_   = k1m_ * MgADP;
    a2_   = k2p_;
    b2_   = (k2m_*(nao/Knao)^3) / ((1.0+nao/Knao)^3 + (1.0+ko/Kko)^2 - 1.0);
    a3_   = (k3p_*(ko/Kko)^2) / ((1.0+nao/Knao)^3 + (1.0+ko/Kko)^2 - 1.0);
    b3_   = (k3m_*P_nak*H_ion) / (1.0 + MgATP/Kmgatp);
    a4_   = (k4p_*MgATP/Kmgatp) / (1.0 + MgATP/Kmgatp);
    b4_   = (k4m_*(ki/Kki)^2) / ((1.0+nai/Knai)^3 + (1.0+ki/Kki)^2 - 1.0);

    x1_   = a4_*a1_*a2_ + b2_*b4_*b3_ + a2_*b4_*b3_ + b3_*a1_*a2_;
    x2_   = b2_*b1_*b4_ + a1_*a2_*a3_ + a3_*b1_*b4_ + a2_*a3_*b4_;
    x3_   = a2_*a3_*a4_ + b3_*b2_*b1_ + b2_*b1_*a4_ + a3_*a4_*b1_;
    x4_   = b4_*b3_*b2_ + a3_*a4_*a1_ + b2_*a4_*a1_ + b3_*b2_*a1_;
    denom_= x1_+x2_+x3_+x4_;
    E1_   = x1_/denom_;  E2_ = x2_/denom_;
    E3_   = x3_/denom_;  E4_ = x4_/denom_;

    zk      = 1.0;
    JnakNa  = 3.0*(E1_*a3_ - E2_*b3_);
    JnakK   = 2.0*(E4_*b1_ - E3_*a1_);
    Pnak    = 30;
    if celltype == 1, Pnak = Pnak * 0.9; end
    if celltype == 2, Pnak = Pnak * 0.7; end
    INaK    = Pnak * (zna*JnakNa + zk*JnakK);

    % IKb, INab, ICab, IpCa
    xkb  = 1.0 / (1.0 + exp(-(v-14.48)/18.34));
    GKb  = 0.003;
    IKb  = GKb * xkb * (v - EK);

    PNab = 3.75e-10;
    INab = PNab * vffrt * (nai*exp(vfrt) - nao) / (exp(vfrt) - 1.0);

    PCab = 2.5e-8;
    ICab = PCab * 4.0 * vffrt * (cai*exp(2.0*vfrt) - 0.341*cao) / (exp(2.0*vfrt) - 1.0);

    GpCa = 0.0005;
    IpCa = GpCa * cai / (0.0005 + cai);

    % --- Stimulus ---
    if (t > (start + n_beat*CL)) && (t < (start + duration + n_beat*CL - dt))
        if Ist == 0
            vrest = v;
        end
        Ist = amp;
    elseif t > (start + duration + n_beat*CL - dt)
        Ist    = 0.0;
        n_beat = n_beat + 1;
    end

    % --- Voltage update ---
    vo = v;
    v  = v - dt*(INa+INaL+Ito+ICaL+ICaNa+ICaK+IKr+IKs+IK1+INaCa+INaK+INab+IKb+IpCa+ICab+Ist);

    % --- dVdt / APD ---
    vdot_old = vdot;
    vdot     = (v - vo) / dt;
    if APD_flag == 0 && v > -40 && vdot < vdot_old
        vdot_max   = vdot_old;
        t_vdot_max = t - dt;
        APD_flag   = 1;
    end
    if APD_flag == 1 && v < 0.9*vrest
        APD      = t - t_vdot_max;
        APD_flag = 0;
    end

    % --- Fluxes, Buffers, Concentrations (FBC) ---
    CaMKb  = CaMKo*(1.0-CaMKt)/(1.0+KmCaM/cass);
    CaMKa  = CaMKb + CaMKt;
    CaMKt  = CaMKt + dt*(aCaMK*CaMKb*(CaMKb+CaMKt) - bCaMK*CaMKt);

    JdiffNa = (nass - nai) / 2.0;
    JdiffK  = (kss  - ki)  / 2.0;
    Jdiff   = (cass - cai) / 0.2;

    bt       = 4.75;
    a_rel    = 0.5 * bt;
    Jrel_inf = a_rel*(-ICaL) / (1.0 + (1.5/cajsr)^8);
    if celltype == 2, Jrel_inf = Jrel_inf * 1.7; end
    tau_rel  = bt / (1.0 + 0.0123/cajsr);
    if tau_rel < 0.005, tau_rel = 0.005; end
    Jrelnp   = Jrel_inf - (Jrel_inf - Jrelnp)*exp(-dt/tau_rel);

    btp        = 1.25 * bt;
    a_relp     = 0.5 * btp;
    Jrel_infp  = a_relp*(-ICaL) / (1.0 + (1.5/cajsr)^8);
    if celltype == 2, Jrel_infp = Jrel_infp * 1.7; end
    tau_relp   = btp / (1.0 + 0.0123/cajsr);
    if tau_relp < 0.005, tau_relp = 0.005; end
    Jrelp      = Jrel_infp - (Jrel_infp - Jrelp)*exp(-dt/tau_relp);

    fJrelp = 1.0 / (1.0 + KmCaMK/CaMKa);
    Jrel   = ((1.0-fJrelp)*Jrelnp + fJrelp*Jrelp) * Jrel_ROS;

    Jupnp = 0.004375*cai / (cai + 0.00092);
    Jupp  = 2.75*0.004375*cai / (cai + 0.00092 - 0.00017);
    if celltype == 1
        Jupnp = Jupnp * 1.3;
        Jupp  = Jupp  * 1.3;
    end
    fJupp = 1.0 / (1.0 + KmCaMK/CaMKa);
    Jleak = 0.0039375 * cansr / 15.0;
    Jup   = ((1.0-fJupp)*Jupnp + fJupp*Jupp - Jleak) * Jup_ROS;

    Jtr = (cansr - cajsr) / 100.0;

    nai  = nai  + dt*(-(INa+INaL+3.0*INaCa_i+3.0*INaK+INab)*Acap/(F*vmyo) + JdiffNa*vss/vmyo);
    nass = nass + dt*(-(ICaNa+3.0*INaCa_ss)*Acap/(F*vss) - JdiffNa);

    ki   = ki   + dt*(-(Ito+IKr+IKs+IK1+IKb+Ist-2.0*INaK)*Acap/(F*vmyo) + JdiffK*vss/vmyo);
    kss  = kss  + dt*(-(ICaK)*Acap/(F*vss) - JdiffK);

    if celltype == 1
        Bcai = 1.0/(1.0 + 1.3*cmdnmax*kmcmdn/(kmcmdn+cai)^2 + trpnmax*kmtrpn/(kmtrpn+cai)^2);
    else
        Bcai = 1.0/(1.0 + cmdnmax*kmcmdn/(kmcmdn+cai)^2 + trpnmax*kmtrpn/(kmtrpn+cai)^2);
    end
    cai   = cai  + dt*(Bcai*(-(IpCa+ICab-2.0*INaCa_i)*Acap/(2.0*F*vmyo) - Jup*vnsr/vmyo + Jdiff*vss/vmyo - V_uni*vmito/vmyo + V_mNaCa*vmito/vmyo - J_mPTP*vmito/vmyo));

    Bcass = 1.0/(1.0 + BSRmax*KmBSR/(KmBSR+cass)^2 + BSLmax*KmBSL/(KmBSL+cass)^2);
    cass  = cass + dt*(Bcass*(-(ICaL-2.0*INaCa_ss)*Acap/(2.0*F*vss) + Jrel*vjsr/vss - Jdiff));

    cansr = cansr + dt*(Jup - Jtr*vjsr/vnsr);

    Bcajsr = 1.0/(1.0 + csqnmax*kmcsqn/(kmcsqn+cajsr)^2);
    cajsr  = cajsr + dt*(Bcajsr*(Jtr - Jrel));

    % --- Mitochondria & ROS update ---
    F_mito      = 96.485;
    R_mito      = 8.314;
    C_p         = 1.8e-3;
    a1_m        = 120.0;
    a2_m        = 3.43;
    f_m         = 0.01;
    NADm_tot    = 2.970;
    p_3         = 0.075;
    k_mPTP      = 8.0e-6;

    V_NaCa_max  = 1.0e-4;
    b_mito      = 0.5;
    deltaPsi0   = 91;
    K_Na_m      = 9.4;
    K_Ca_m      = 3.75e-4;
    n_naca      = 3;

    V_uni_max   = 0.0275;
    K_trans     = 0.019;
    K_act       = 3.8e-4;
    L_uni       = 110;
    n_a         = 2.8;
    delta_uni   = 3e-4;

    K_AGC       = 0.14e-3;
    p_4         = 0.01;
    q_1         = 0.2244;
    q_2         = 0.1e-3;
    V_AGC_r     = 0.025e-3;
    k_GLY       = 0.05e-3;

    q_3         = 100.0e-3;
    q_4         = 177.0;
    q_5         = 5.0;
    q_6         = 10000.0e-3;
    q_7         = 190.0;
    q_8         = 8.5;
    q_9         = 0.0020e-3;
    q_10        = -0.030e-3;
    V_ANT_r     = 8.123e-3;
    V_F1F0_r    = 3.6e-3;
    KATP        = 3.5e-3;
    theta_m     = 0.35;
    k_ETC       = 0.764e-3;

    RT_over_F   = 26.729246592691901;
    NADPH       = 1.0;
    b_ROS       = 1.0e4;
    Kcc         = 0.01;
    G_L_ros     = 7.82e-8;
    G_max_ros   = 7.82e-6;
    Kappa       = 70e-3;
    Em_ROS      = 4.0;
    k1_SOD      = 1.2e3;
    k3_SOD      = 24;
    k5_SOD      = 0.25e-3;
    etSOD       = 1.5e-3;
    Kki_ros     = 0.5;
    k1_CAT      = 17.0;
    EtCAT       = 0.01;
    fr          = 0.05;
    EtGPX       = 0.01;
    Phi1        = 0.5e-2;
    Phi2        = 0.75;
    k1_GR       = 5.0e-3;
    EtGR        = 0.01;
    Km_GSSG     = 0.06;
    Km_NADPH    = 0.015;
    GT          = 1.0;
    j_Vt2SO2m   = 0.1;

    V_uni    = V_uni_max * ( ((cai/K_trans) * (1+cai/K_trans)^3 * ((2*F_mito)*(Psi-deltaPsi0)/(R_mito*T))) / ...
               ((1+cai/K_trans)^4 + (L_uni/(1+cai/K_act)^n_a) * (1 - exp(-(2*F_mito)*(Psi-deltaPsi0)/(R_mito*T)))) );

    V_mNaCa  = V_NaCa_max * (exp((b_mito*F_mito*(Psi-deltaPsi0)/(R_mito*T))) * log(cai/Cam)) / ...
               ((1 + (K_Na_m/nai)^n_naca) * (1 + K_Ca_m/Cam));

    J_mPTP   = (k_mPTP*(cai - Cam)) * exp(p_3*Psi);

    NADm     = NADm_tot - NADHm;
    J_PDH    = k_GLY * (1/(q_1 + NADHm/NADm)) * (Cam/(q_2+Cam));

    J_AGC    = V_AGC_r * (cai/(K_AGC+cai)) * (q_2/(q_2+Cam)) * exp(p_4*Psi);

    J_ETC    = k_ETC * (NADHm/(q_3+NADHm)) * (1/(1+exp((Psi-q_4)/q_5)));

    J_F1F0   = V_F1F0_r * (q_6/(q_6+ATPm)) * (1/(1+exp((q_7-Psi)/q_8)));

    J_ANT    = V_ANT_r * ((ADP/(ADP + ATP*exp(-(theta_m*F_mito)*Psi/(R_mito*T)))) - ...
               (ADPm/(ADPm + ATPm*exp(((1-theta_m)*F_mito)*Psi/(R_mito*T))))) * (1/(1+KATP/ADP));

    J_Hleak  = q_9*Psi + q_10;

    VIMAC2   = -1.0*(1.0e-3 + b_ROS/(1.0+Kcc/ROSi)) * ...
               (G_L_ros + G_max_ros/(1+exp(Kappa*(Em_ROS-(-Psi))))) * (-Psi);

    Vt2SO2m  = -j_Vt2SO2m * ((-Psi - RT_over_F*log(ROSm/ROSi))/Psi) * ...
               (-1*(1.0e-3+b_ROS/(1+Kcc/ROSi))*(G_L_ros+G_max_ros/(1+exp(Kappa*(Em_ROS-(-Psi)))))*(-Psi));

    VSOD     = 2*k1_SOD*k5_SOD*(k1_SOD+k3_SOD*(1+H2O2/Kki_ros))*etSOD*ROSi / ...
               (k5_SOD*(2*k1_SOD+k3_SOD*(1+H2O2/Kki_ros)) + k1_SOD*k3_SOD*(1+H2O2/Kki_ros)*ROSi);

    VCAT     = 2*k1_CAT*EtCAT*exp(-fr*H2O2)*H2O2;

    VGPX     = EtGPX*H2O2*GSH / (Phi1*GSH + Phi2*H2O2);

    VGR      = k1_GR*EtGR / (1 + Km_GSSG/(0.5*(GT-GSH)) + Km_NADPH/NADPH + Km_GSSG*Km_NADPH/((0.5*(GT-GSH))/NADPH));

    dCam   = delta_uni * (V_uni - V_mNaCa + J_mPTP);
    dNADHm = J_PDH - J_ETC + J_AGC;
    dADPm  = J_ANT - J_F1F0;
    dATPm  = J_F1F0 - J_ANT;
    dPsi   = (a1_m*J_ETC - a2_m*J_F1F0 - J_ANT - J_Hleak - V_mNaCa - 2*V_uni - 2*J_mPTP - J_AGC) / C_p;

    dROSm  = (ETC_Leak*J_ETC) - Vt2SO2m;
    dROSi  = Vt2SO2m - VSOD;
    dH2O2  = VSOD - VCAT - VGPX;
    dGSH   = VGR - VGPX;

    Cam   = Cam   + dCam   * dt;
    NADHm = NADHm + dNADHm * dt;
    ATPm  = ATPm  + dATPm  * dt;
    ADPm  = ADPm  + dADPm  * dt;
    Psi   = Psi   + dPsi   * dt;
    ROSm  = ROSm  + dROSm  * dt;
    ROSi  = ROSi  + dROSi  * dt;
    H2O2  = H2O2  + dH2O2  * dt;
    GSH   = GSH   + dGSH   * dt;

    % --- Progress printout ---
    if mod(counter, 500000) == 0
        fprintf('%.1f%% complete\n', t/ft*100);
    end

    % --- Output to files ---
    if mod(counter, skip) == 0 && t >= ft - beatssave*CL
        t_out = t - (ft - beatssave*CL);

        fprintf(fid1, '%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\n', ...
            t_out, v, cai, cass, cansr, cajsr, Jrel, Jup, INa, INaL, Ito, ICaL, ICaNa, ICaK, ...
            IKr, IKs, IK1, INaCa_i, INaCa_ss, INaCa, INaK, IKb, INab, IpCa, ICab, APD, ...
            ROSi, ROSm, H2O2, GSH, Psi, NADHm, Cam);
    end

    counter = counter + 1;

end % end main while loop

fclose(fid1);


end % end function
