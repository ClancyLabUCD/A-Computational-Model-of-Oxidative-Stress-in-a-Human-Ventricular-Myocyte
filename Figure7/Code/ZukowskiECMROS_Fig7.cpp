// C++ Implementation of the Zukowski ECM-ROS Model
// Figure 7: nested sweep over pacing cycle length (CL) and fixed ROSi
// condition (base, high)
//
// 4 pacing conditions (CL = 500, 750, 1000, 2000 ms), each with its own
// steady-state initial conditions, x 2 fixed ROSi conditions. ROSi is
// clamped to a constant value for the full run (not integrated) and
// drives GNaL_factor, pca_factor, Jrel_ROS, and Jup_ROS.
// 8 total runs, each restarting from that pacing rate's original ICs.
//
// Output files: output_<CL>CL_<condition>.txt
//   e.g. output_1000CL_base.txt, output_1000CL_high.txt,
//        output_500CL_base.txt, output_500CL_high.txt, etc.

#include <math.h>
#include <iostream>
#include <string>
using namespace std;
#include <fstream>
using std::ifstream;
using std::ofstream;

void revpots();//compute reversal potentials
void RGC();//compute rates, gates, and currents
void stimulus();//determine the value for the periodic stimulus
void voltage();//calculate the new membrane voltage
void dVdt_APD();//caluculate voltage derivative and APD90
void FBC();//calculate fluxes, buffers, and concentrations

void updateMitochondria(); //mitochondria and ROS

void setIC_500CL();
void setIC_750CL();
void setIC_1000CL();
void setIC_2000CL();
void resetTimers();

double CL=1000;//pacing cycle length (set per pacing condition in main)
double ft=50*CL;//final time (20 beats, set per pacing condition in main)
const int skip=1;//number of timesetps to skip in sampling of data in output file
const double safetime=25.0;//time from the beginning of each beat during which dt is fixed to small values
const double beatssave=1;//number of beats to save in the output

const double amp=-80;//stimulus amplitude in uA/uF
const double start=100;//start time of the stimulus, relative to each beat
const double duration=0.5;//duration of the stimulus in ms

const int celltype=0;  //endo = 0, epi = 1, M = 2


//define global variables - ORd
double v, nai, nass, ki, kss, cai, cass, cansr, cajsr, m, hf, hs, j, hsp, jp, mL, hL, hLp, a, iF, iS, ap, iFp, iSp, d, ff, fs, fcaf, fcas, jca, nca, ffp, fcafp, xrf, xrs, xs1, xs2, xk1, Jrelnp, Jrelp, CaMKt;


//Define all mito and ROS global variables
double NADHm, Cam, Psi, ATPm, ADPm;
double ROSm, ROSi, H2O2, GSH;

//constants
double const nao=140.0;//extracellular sodium in mM
double const cao=1.8;//extracellular calcium in mM
double const ko=5.4;//extracellular potassium in mM

//buffer paramaters
double const BSRmax=0.047;
double const KmBSR=0.00087;
double const BSLmax=1.124;
double const KmBSL=0.0087;
double const cmdnmax=0.05;
double const kmcmdn=0.00238;
double const trpnmax=0.07;
double const kmtrpn=0.0005;
double const csqnmax=10.0;
double const kmcsqn=0.8;

//CaMK paramaters
double const aCaMK=0.05;
double const bCaMK=0.00068;
double const CaMKo=0.05;
double const KmCaM=0.0015;
double const KmCaMK=0.15;

//physical constants
double const R=8314.0;
double const T=310.0;
double const F=96485.0;

//cell geometry
double const L=0.01;
double const rad=0.0011;
double const vcell=1000*3.14*rad*rad*L;
double const Ageo=2*3.14*rad*rad+2*3.14*rad*L;
double const Acap=2*Ageo;
double const vmyo=0.68*vcell;
double const vmito=0.26*vcell;
double const vsr=0.06*vcell;
double const vnsr=0.0552*vcell;
double const vjsr=0.0048*vcell;
double const vss=0.02*vcell;

//introduce varaibles for reversal potentials, currents, fluxes, and CaMK
double ENa,EK,EKs;
double INa,INaL,Ito,ICaL,ICaNa,ICaK,IKr,IKs,IK1,INaCa_i,INaCa_ss,INaCa,INaK,IKb,INab,IpCa,ICab,Ist;
double Jrel,Jup,Jtr,Jdiff,JdiffNa,JdiffK,Jleak;
double CaMKa,CaMKb;

//introduce APD, timing, and counting parameters
int APD_flag=0;
double APD;
double t_vdot_max;
double vrest;
double vo=v;
double dt=0.005;
double t0=0;
double t=0;
double dto;
double vdot_old;
double vdot=0;
double vdot_max;
int p=1;
int n=0;
int counter=1;


//Define all mito fluxes and ROS rates
double V_uni, V_mNaCa, J_mPTP, J_PDH, J_AGC, J_ETC, J_F1F0, J_ANT, J_Hleak;
double Vt2SO2m, VSOD, VCAT, VGPX, VGR, VIMAC2;

// LTCC ROS
double pca_factor;

//INaL ROS
double GNaL_factor;

//RyR ROS
double Jrel_ROS;

//SERCA ROS
double Jup_ROS;

//mito & ros constants
double ATP = 7.7107; //Cortassa IC
double ADP = 0.2893; //Cortassa IC
double ETC_Leak = 0.3;

//------------------------------------------------------------------
// Pacing conditions to sweep. Each has its own steady-state ICs
// (set via its ICSetter function pointer) and a label used in the
// output filename.
//------------------------------------------------------------------
typedef void (*ICSetter)();

struct PacingCondition {
    double CLval;
    const char* label;
    ICSetter setIC;
};

const int numPacing = 4;
const PacingCondition pacingConditions[numPacing] = {
    {500.0,  "500CL",  setIC_500CL},
    {750.0,  "750CL",  setIC_750CL},
    {1000.0, "1000CL", setIC_1000CL},
    {2000.0, "2000CL", setIC_2000CL}
};

//------------------------------------------------------------------
// 2 fixed ROSi conditions to sweep, each with a label used in the
// output filename.
//------------------------------------------------------------------
struct ROSiCondition {
    double ROSi_const;
    const char* label;
};

const int numROSi = 3;
const ROSiCondition rosiConditions[numROSi] = {
    {1E-6, "base"},
    {200E-3, "200"},
    {0.5,  "500"}
};

int main()
{
    for (int pc = 0; pc < numPacing; pc++)
    {
        CL = pacingConditions[pc].CLval;
        ft = 50*CL; //50 beats

        for (int rc = 0; rc < numROSi; rc++)
        {
            // Reset to this pacing rate's original steady-state ICs,
            // clamp ROSi to this condition's fixed value, then reset
            // all timers/counters for a clean run
            pacingConditions[pc].setIC();
            ROSi = rosiConditions[rc].ROSi_const;
            resetTimers();

            std::string fname = std::string("output_") + pacingConditions[pc].label
                                 + "_" + rosiConditions[rc].label + ".txt";
            ofstream myfile(fname.c_str());

            cout << "Running " << pacingConditions[pc].label << " / "
                 << rosiConditions[rc].label << " (CL=" << CL
                 << ", ROSi=" << ROSi << ") -> " << fname << endl;

            while (t<=ft)
            {

                GNaL_factor = 1.0355 / (1.0 + exp(-9000.0 * (ROSi - 5.5E-4))) + 0.9823;
                pca_factor  = 3.1064 / (1.0 + exp(-9000.0 * (ROSi - 5.5E-4))) + 0.9468;

                Jrel_ROS = 1.0 + (8.3 - 1.0) * (1.0 - exp(-27.01 * ROSi));
                Jup_ROS = 1.02 * exp(-43.67*ROSi);

                t=t+dt; //fixed time step
                revpots();
                RGC();
                stimulus();
                vo=v;
                voltage();
                dVdt_APD();
                FBC();
                updateMitochondria();


                if (counter%500000==0)
                {
                    cout<<t/ft*100<<"% complete"<<endl;//output runtime progress to the screen
                }

                if (counter%skip==0 && t>=ft-beatssave*CL)//save results ot output file when the sampling interval and time are correct
                {
                    myfile << t-(ft-beatssave*CL)<< "\t" << v << "\t" << cai << "\t" << ICaL << "\t" << INaL << "\t" << ROSi << "\t" << APD << endl;

                }

                counter++;//increase the loop counter

            }

            myfile.close();//close the output file
        }
    }

    return 0;
}

void resetTimers()
{
    // Timing / counting / stimulus state - must be reset before each
    // run so every condition starts from an identical, clean simulation
    t = 0;
    t0 = 0;
    counter = 1;
    n = 0;
    p = 1;
    APD_flag = 0;
    vdot = 0;
    vdot_old = 0;
    vo = v;
    Ist = 0;
}

void setIC_500CL()
{
    v = -86.9492;
    nai = 8.10827;
    nass = 8.10848;
    ki = 138.949;
    kss = 138.949;
    cai = 0.000142645;
    cass = 0.00014966;
    cansr = 2.31056;
    cajsr = 1.50691;
    m = 0.00816396;
    hf = 0.660449;
    hs = 0.660082;
    j = 0.655344;
    hsp = 0.411231;
    jp = 0.642165;
    mL = 0.000229934;
    hL = 0.31271;
    hLp = 0.156088;
    a = 0.00107482;
    iF = 0.999463;
    iS = 0.197581;
    ap = 0.000547669;
    iFp = 0.999463;
    iSp = 0.227052;
    d = 3.00306e-09;
    ff = 1;
    fs = 0.770972;
    fcaf = 1;
    fcas = 0.953981;
    jca = 0.957778;
    nca = 0.0242054;
    ffp = 0.99997;
    fcafp = 0.999998;
    xrf = 0.0207583;
    xrs = 0.820552;
    xs1 = 0.468496;
    xs2 = 0.000759883;
    xk1 = 0.997032;
    Jrelnp = 2.5067e-07;
    Jrelp = 3.10107e-07;
    CaMKt = 0.0697944;

    Psi = 190.872;
    ATPm = 0.751494;
    ADPm = 9.24848;
    Cam = 0.000259062;
    NADHm = 1.36278;
    ROSm = 2.83072e-06;
    H2O2 = 5.36007e-06;
    GSH = 0.943777;
}

void setIC_750CL()
{
    v = -87.4232;
    nai = 7.58005;
    nass = 7.58017;
    ki = 141.352;
    kss = 141.351;
    cai = 0.000102997;
    cass = 0.000103564;
    cansr = 1.78786;
    cajsr = 1.56652;
    m = 0.00778408;
    hf = 0.677698;
    hs = 0.677615;
    j = 0.677136;
    hsp = 0.431252;
    jp = 0.676726;
    mL = 0.000210133;
    hL = 0.437775;
    hLp = 0.218124;
    a = 0.00104094;
    iF = 0.999506;
    iS = 0.387382;
    ap = 0.000530396;
    iFp = 0.999506;
    iSp = 0.432837;
    d = 2.68409e-09;
    ff = 1;
    fs = 0.856747;
    fcaf = 1;
    fcas = 0.995075;
    jca = 0.997969;
    nca = 0.00587642;
    ffp = 1;
    fcafp = 1;
    xrf = 0.000133512;
    xrs = 0.647405;
    xs1 = 0.356641;
    xs2 = 0.000206106;
    xk1 = 0.99691;
    Jrelnp = 2.73841e-07;
    Jrelp = 3.41492e-07;
    CaMKt = 0.0240471;

    Psi = 189.727;
    ATPm = 0.74602;
    ADPm = 9.25395;
    Cam = 0.000162353;
    NADHm = 1.37268;
    ROSm = 2.10087e-06;
    H2O2 = 6.6428e-06;
    GSH = 0.944516;
}

void setIC_1000CL()
{
    v = -87.821;
    nai = 7.22427;
    nass = 7.22436;
    ki = 143.735;
    kss = 143.735;
    cai = 8.8428e-05;
    cass = 8.75668e-05;
    cansr = 1.62169;
    cajsr = 1.55005;
    m = 0.00747891;
    hf = 0.691807;
    hs = 0.691781;
    j = 0.691637;
    hsp = 0.44756;
    jp = 0.691538;
    mL = 0.000194841;
    hL = 0.488447;
    hLp = 0.257703;
    a = 0.00101338;
    iF = 0.99954;
    iS = 0.538357;
    ap = 0.000516348;
    iFp = 0.99954;
    iSp = 0.590293;
    d = 2.44307e-09;
    ff = 1;
    fs = 0.901579;
    fcaf = 1;
    fcas = 0.999516;
    jca = 0.999912;
    nca = 0.00309203;
    ffp = 1;
    fcafp = 1;
    xrf = 8.778e-06;
    xrs = 0.502847;
    xs1 = 0.283207;
    xs2 = 0.000196824;
    xk1 = 0.996807;
    Jrelnp = 2.46597e-07;
    Jrelp = 3.07994e-07;
    CaMKt = 0.0131135;

    Psi = 189.282;
    ATPm = 0.743595;
    ADPm = 9.25638;
    Cam = 0.000120513;
    NADHm = 1.34642;
    ROSm = 1.82385e-06;
    H2O2 = 7.20523e-06;
    GSH = 0.944713;
}

void setIC_2000CL()
{
    v = -87.7296;
    nai = 6.18426;
    nass = 6.18431;
    ki = 144.054;
    kss = 144.054;
    cai = 7.40224e-05;
    cass = 7.25597e-05;
    cansr = 1.36923;
    cajsr = 1.36919;
    m = 0.00754801;
    hf = 0.688594;
    hs = 0.688594;
    j = 0.688593;
    hsp = 0.443942;
    jp = 0.688592;
    mL = 0.000198256;
    hL = 0.503804;
    hLp = 0.298266;
    a = 0.00101964;
    iF = 0.999532;
    iS = 0.854844;
    ap = 0.000519539;
    iFp = 0.999532;
    iSp = 0.89058;
    d = 2.49642e-09;
    ff = 1;
    fs = 0.970364;
    fcaf = 1;
    fcas = 1;
    jca = 1;
    nca = 0.00150006;
    ffp = 1;
    fcafp = 1;
    xrf = 8.34128e-06;
    xrs = 0.181988;
    xs1 = 0.133072;
    xs2 = 0.000198756;
    xk1 = 0.99683;
    Jrelnp = 1.48807e-07;
    Jrelp = 1.86006e-07;
    CaMKt = 0.0033394;

    Psi = 188.833;
    ATPm = 0.734269;
    ADPm = 9.2657;
    Cam = 7.68724e-05;
    NADHm = 1.20685;
    ROSm = 1.58017e-06;
    H2O2 = 7.76537e-06;
    GSH = 0.944785;
}

void revpots()
{
ENa=(R*T/F)*log(nao/nai);
EK=(R*T/F)*log(ko/ki);
EKs=(R*T/F)*log((ko+0.01833*nao)/(ki+0.01833*nai));
}

void RGC()
{
CaMKb=CaMKo*(1.0-CaMKt)/(1.0+KmCaM/cass);
CaMKa=CaMKb+CaMKt;
double vffrt=v*F*F/(R*T);
double vfrt=v*F/(R*T);

double mss=1.0/(1.0+exp((-(v+39.57))/9.871));
double tm=1.0/(6.765*exp((v+11.64)/34.77)+8.552*exp(-(v+77.42)/5.955));
m=mss-(mss-m)*exp(-dt/tm);
double hss=1.0/(1+exp((v+82.90)/6.086));
double thf=1.0/(1.432e-5*exp(-(v+1.196)/6.285)+6.149*exp((v+0.5096)/20.27));
double ths=1.0/(0.009794*exp(-(v+17.95)/28.05)+0.3343*exp((v+5.730)/56.66));
double Ahf=0.99;
double Ahs=1.0-Ahf;
hf=hss-(hss-hf)*exp(-dt/thf);
hs=hss-(hss-hs)*exp(-dt/ths);
double h=Ahf*hf+Ahs*hs;
double jss=hss;
double tj=2.038+1.0/(0.02136*exp(-(v+100.6)/8.281)+0.3052*exp((v+0.9941)/38.45));
j=jss-(jss-j)*exp(-dt/tj);
double hssp=1.0/(1+exp((v+89.1)/6.086));
double thsp=3.0*ths;
hsp=hssp-(hssp-hsp)*exp(-dt/thsp);
double hp=Ahf*hf+Ahs*hsp;
double tjp=1.46*tj;
jp=jss-(jss-jp)*exp(-dt/tjp);
double GNa=75;
double fINap=(1.0/(1.0+KmCaMK/CaMKa));
INa=GNa*(v-ENa)*m*m*m*((1.0-fINap)*h*j+fINap*hp*jp);

double mLss=1.0/(1.0+exp((-(v+42.85))/5.264));
double tmL=tm;
mL=mLss-(mLss-mL)*exp(-dt/tmL);
double hLss=1.0/(1.0+exp((v+87.61)/7.488));
double thL=200.0;
hL=hLss-(hLss-hL)*exp(-dt/thL);
double hLssp=1.0/(1.0+exp((v+93.81)/7.488));
double thLp=3.0*thL;
hLp=hLssp-(hLssp-hLp)*exp(-dt/thLp);
double GNaL=0.0075*GNaL_factor;
if (celltype==1)
{
GNaL*=0.6;
}
double fINaLp=(1.0/(1.0+KmCaMK/CaMKa));
INaL=GNaL*(v-ENa)*mL*((1.0-fINaLp)*hL+fINaLp*hLp);

double ass=1.0/(1.0+exp((-(v-14.34))/14.82));
double ta=1.0515/(1.0/(1.2089*(1.0+exp(-(v-18.4099)/29.3814)))+3.5/(1.0+exp((v+100.0)/29.3814)));
a=ass-(ass-a)*exp(-dt/ta);
double iss=1.0/(1.0+exp((v+43.94)/5.711));
double delta_epi;
if (celltype==1)
{
delta_epi=1.0-(0.95/(1.0+exp((v+70.0)/5.0)));
}
else
{
delta_epi=1.0;
}
double tiF=4.562+1/(0.3933*exp((-(v+100.0))/100.0)+0.08004*exp((v+50.0)/16.59));
double tiS=23.62+1/(0.001416*exp((-(v+96.52))/59.05)+1.780e-8*exp((v+114.1)/8.079));
tiF*=delta_epi;
tiS*=delta_epi;
double AiF=1.0/(1.0+exp((v-213.6)/151.2));
double AiS=1.0-AiF;
iF=iss-(iss-iF)*exp(-dt/tiF);
iS=iss-(iss-iS)*exp(-dt/tiS);
double i=AiF*iF+AiS*iS;
double assp=1.0/(1.0+exp((-(v-24.34))/14.82));
ap=assp-(assp-ap)*exp(-dt/ta);
double dti_develop=1.354+1.0e-4/(exp((v-167.4)/15.89)+exp(-(v-12.23)/0.2154));
double dti_recover=1.0-0.5/(1.0+exp((v+70.0)/20.0));
double tiFp=dti_develop*dti_recover*tiF;
double tiSp=dti_develop*dti_recover*tiS;
iFp=iss-(iss-iFp)*exp(-dt/tiFp);
iSp=iss-(iss-iSp)*exp(-dt/tiSp);
double ip=AiF*iFp+AiS*iSp;
double Gto=0.02;
if (celltype==1)
{
Gto*=4.0;
}
if (celltype==2)
{
Gto*=4.0;
}
double fItop=(1.0/(1.0+KmCaMK/CaMKa));
Ito=Gto*(v-EK)*((1.0-fItop)*a*i+fItop*ap*ip);

double dss=1.0/(1.0+exp((-(v+3.940))/4.230));
double td=0.6+1.0/(exp(-0.05*(v+6.0))+exp(0.09*(v+14.0)));
d=dss-(dss-d)*exp(-dt/td);
double fss=1.0/(1.0+exp((v+19.58)/3.696));
double tff=7.0+1.0/(0.0045*exp(-(v+20.0)/10.0)+0.0045*exp((v+20.0)/10.0));
double tfs=1000.0+1.0/(0.000035*exp(-(v+5.0)/4.0)+0.000035*exp((v+5.0)/6.0));
double Aff=0.6;
double Afs=1.0-Aff;
ff=fss-(fss-ff)*exp(-dt/tff);
fs=fss-(fss-fs)*exp(-dt/tfs);
double f=Aff*ff+Afs*fs;
double fcass=fss;
double tfcaf=7.0+1.0/(0.04*exp(-(v-4.0)/7.0)+0.04*exp((v-4.0)/7.0));
double tfcas=100.0+1.0/(0.00012*exp(-v/3.0)+0.00012*exp(v/7.0));
double Afcaf=0.3+0.6/(1.0+exp((v-10.0)/10.0));
double Afcas=1.0-Afcaf;
fcaf=fcass-(fcass-fcaf)*exp(-dt/tfcaf);
fcas=fcass-(fcass-fcas)*exp(-dt/tfcas);
double fca=Afcaf*fcaf+Afcas*fcas;
double tjca=75.0;
jca=fcass-(fcass-jca)*exp(-dt/tjca);
double tffp=2.5*tff;
ffp=fss-(fss-ffp)*exp(-dt/tffp);
double fp=Aff*ffp+Afs*fs;
double tfcafp=2.5*tfcaf;
fcafp=fcass-(fcass-fcafp)*exp(-dt/tfcafp);
double fcap=Afcaf*fcafp+Afcas*fcas;
double Kmn=0.002;
double k2n=1000.0;
double km2n=jca*1.0;
double anca=1.0/(k2n/km2n+pow(1.0+Kmn/cass,4.0));
nca=anca*k2n/km2n-(anca*k2n/km2n-nca)*exp(-km2n*dt);
double PhiCaL=4.0*vffrt*(cass*exp(2.0*vfrt)-0.341*cao)/(exp(2.0*vfrt)-1.0);
double PhiCaNa=1.0*vffrt*(0.75*nass*exp(1.0*vfrt)-0.75*nao)/(exp(1.0*vfrt)-1.0);
double PhiCaK=1.0*vffrt*(0.75*kss*exp(1.0*vfrt)-0.75*ko)/(exp(1.0*vfrt)-1.0);
double zca=2.0;
double PCa=0.0001;
if (celltype==1)
{
PCa*=1.2;
}
if (celltype==2)
{
PCa*=2.5;
}
double PCap=(1.1*PCa)*pca_factor;
double PCaNa=0.00125*PCa;
double PCaK=3.574e-4*PCa;
double PCaNap=0.00125*PCap;
double PCaKp=3.574e-4*PCap;
double fICaLp=(1.0/(1.0+KmCaMK/CaMKa));
ICaL=(1.0-fICaLp)*PCa*PhiCaL*d*(f*(1.0-nca)+jca*fca*nca)+fICaLp*PCap*PhiCaL*d*(fp*(1.0-nca)+jca*fcap*nca);
ICaNa=(1.0-fICaLp)*PCaNa*PhiCaNa*d*(f*(1.0-nca)+jca*fca*nca)+fICaLp*PCaNap*PhiCaNa*d*(fp*(1.0-nca)+jca*fcap*nca);
ICaK=(1.0-fICaLp)*PCaK*PhiCaK*d*(f*(1.0-nca)+jca*fca*nca)+fICaLp*PCaKp*PhiCaK*d*(fp*(1.0-nca)+jca*fcap*nca);

double xrss=1.0/(1.0+exp((-(v+8.337))/6.789));
double txrf=12.98+1.0/(0.3652*exp((v-31.66)/3.869)+4.123e-5*exp((-(v-47.78))/20.38));
double txrs=1.865+1.0/(0.06629*exp((v-34.70)/7.355)+1.128e-5*exp((-(v-29.74))/25.94));
double Axrf=1.0/(1.0+exp((v+54.81)/38.21));
double Axrs=1.0-Axrf;
xrf=xrss-(xrss-xrf)*exp(-dt/txrf);
xrs=xrss-(xrss-xrs)*exp(-dt/txrs);
double xr=Axrf*xrf+Axrs*xrs;
double rkr=1.0/(1.0+exp((v+55.0)/75.0))*1.0/(1.0+exp((v-10.0)/30.0));
double GKr=0.046;
if (celltype==1)
{
GKr*=1.3;
}
if (celltype==2)
{
GKr*=0.8;
}
IKr=GKr*sqrt(ko/5.4)*xr*rkr*(v-EK);

double xs1ss=1.0/(1.0+exp((-(v+11.60))/8.932));
double txs1=817.3+1.0/(2.326e-4*exp((v+48.28)/17.80)+0.001292*exp((-(v+210.0))/230.0));
xs1=xs1ss-(xs1ss-xs1)*exp(-dt/txs1);
double xs2ss=xs1ss;
double txs2=1.0/(0.01*exp((v-50.0)/20.0)+0.0193*exp((-(v+66.54))/31.0));
xs2=xs2ss-(xs2ss-xs2)*exp(-dt/txs2);
double KsCa=1.0+0.6/(1.0+pow(3.8e-5/cai,1.4));
double GKs=0.0034;
if (celltype==1)
{
GKs*=1.4;
}
IKs=GKs*KsCa*xs1*xs2*(v-EKs);

double xk1ss=1.0/(1.0+exp(-(v+2.5538*ko+144.59)/(1.5692*ko+3.8115)));
double txk1=122.2/(exp((-(v+127.2))/20.36)+exp((v+236.8)/69.33));
xk1=xk1ss-(xk1ss-xk1)*exp(-dt/txk1);
double rk1=1.0/(1.0+exp((v+105.8-2.6*ko)/9.493));
double GK1=0.1908;
if (celltype==1)
{
GK1*=1.2;
}
if (celltype==2)
{
GK1*=1.3;
}
IK1=GK1*sqrt(ko)*rk1*xk1*(v-EK);

double kna1=15.0;
double kna2=5.0;
double kna3=88.12;
double kasymm=12.5;
double wna=6.0e4;
double wca=6.0e4;
double wnaca=5.0e3;
double kcaon=1.5e6;
double kcaoff=5.0e3;
double qna=0.5224;
double qca=0.1670;
double hca=exp((qca*v*F)/(R*T));
double hna=exp((qna*v*F)/(R*T));
double h1=1+nai/kna3*(1+hna);
double h2=(nai*hna)/(kna3*h1);
double h3=1.0/h1;
double h4=1.0+nai/kna1*(1+nai/kna2);
double h5=nai*nai/(h4*kna1*kna2);
double h6=1.0/h4;
double h7=1.0+nao/kna3*(1.0+1.0/hna);
double h8=nao/(kna3*hna*h7);
double h9=1.0/h7;
double h10=kasymm+1.0+nao/kna1*(1.0+nao/kna2);
double h11=nao*nao/(h10*kna1*kna2);
double h12=1.0/h10;
double k1=h12*cao*kcaon;
double k2=kcaoff;
double k3p=h9*wca;
double k3pp=h8*wnaca;
double k3=k3p+k3pp;
double k4p=h3*wca/hca;
double k4pp=h2*wnaca;
double k4=k4p+k4pp;
double k5=kcaoff;
double k6=h6*cai*kcaon;
double k7=h5*h2*wna;
double k8=h8*h11*wna;
double x1=k2*k4*(k7+k6)+k5*k7*(k2+k3);
double x2=k1*k7*(k4+k5)+k4*k6*(k1+k8);
double x3=k1*k3*(k7+k6)+k8*k6*(k2+k3);
double x4=k2*k8*(k4+k5)+k3*k5*(k1+k8);
double E1=x1/(x1+x2+x3+x4);
double E2=x2/(x1+x2+x3+x4);
double E3=x3/(x1+x2+x3+x4);
double E4=x4/(x1+x2+x3+x4);
double KmCaAct=150.0e-6;
double allo=1.0/(1.0+pow(KmCaAct/cai,2.0));
double zna=1.0;
double JncxNa=3.0*(E4*k7-E1*k8)+E3*k4pp-E2*k3pp;
double JncxCa=E2*k2-E1*k1;
double Gncx=0.0008;
if (celltype==1)
{
Gncx*=1.1;
}
if (celltype==2)
{
Gncx*=1.4;
}
INaCa_i=0.8*Gncx*allo*(zna*JncxNa+zca*JncxCa);

h1=1+nass/kna3*(1+hna);
h2=(nass*hna)/(kna3*h1);
h3=1.0/h1;
h4=1.0+nass/kna1*(1+nass/kna2);
h5=nass*nass/(h4*kna1*kna2);
h6=1.0/h4;
h7=1.0+nao/kna3*(1.0+1.0/hna);
h8=nao/(kna3*hna*h7);
h9=1.0/h7;
h10=kasymm+1.0+nao/kna1*(1+nao/kna2);
h11=nao*nao/(h10*kna1*kna2);
h12=1.0/h10;
k1=h12*cao*kcaon;
k2=kcaoff;
k3p=h9*wca;
k3pp=h8*wnaca;
k3=k3p+k3pp;
k4p=h3*wca/hca;
k4pp=h2*wnaca;
k4=k4p+k4pp;
k5=kcaoff;
k6=h6*cass*kcaon;
k7=h5*h2*wna;
k8=h8*h11*wna;
x1=k2*k4*(k7+k6)+k5*k7*(k2+k3);
x2=k1*k7*(k4+k5)+k4*k6*(k1+k8);
x3=k1*k3*(k7+k6)+k8*k6*(k2+k3);
x4=k2*k8*(k4+k5)+k3*k5*(k1+k8);
E1=x1/(x1+x2+x3+x4);
E2=x2/(x1+x2+x3+x4);
E3=x3/(x1+x2+x3+x4);
E4=x4/(x1+x2+x3+x4);
KmCaAct=150.0e-6;
allo=1.0/(1.0+pow(KmCaAct/cass,2.0));
JncxNa=3.0*(E4*k7-E1*k8)+E3*k4pp-E2*k3pp;
JncxCa=E2*k2-E1*k1;
INaCa_ss=0.2*Gncx*allo*(zna*JncxNa+zca*JncxCa);

INaCa=INaCa_i+INaCa_ss;

double k1p=949.5;
double k1m=182.4;
double k2p=687.2;
double k2m=39.4;
k3p=1899.0;
double k3m=79300.0;
k4p=639.0;
double k4m=40.0;
double Knai0=9.073;
double Knao0=27.78;
double delta=-0.1550;
double Knai=Knai0*exp((delta*v*F)/(3.0*R*T));
double Knao=Knao0*exp(((1.0-delta)*v*F)/(3.0*R*T));
double Kki=0.5;
double Kko=0.3582;
double MgADP=0.05;
double MgATP=9.8;
double Kmgatp=1.698e-7;
double H=1.0e-7;
double eP=4.2;
double Khp=1.698e-7;
double Knap=224.0;
double Kxkur=292.0;
double P=eP/(1.0+H/Khp+nai/Knap+ki/Kxkur);
double a1=(k1p*pow(nai/Knai,3.0))/(pow(1.0+nai/Knai,3.0)+pow(1.0+ki/Kki,2.0)-1.0);
double b1=k1m*MgADP;
double a2=k2p;
double b2=(k2m*pow(nao/Knao,3.0))/(pow(1.0+nao/Knao,3.0)+pow(1.0+ko/Kko,2.0)-1.0);
double a3=(k3p*pow(ko/Kko,2.0))/(pow(1.0+nao/Knao,3.0)+pow(1.0+ko/Kko,2.0)-1.0);
double b3=(k3m*P*H)/(1.0+MgATP/Kmgatp);
double a4=(k4p*MgATP/Kmgatp)/(1.0+MgATP/Kmgatp);
double b4=(k4m*pow(ki/Kki,2.0))/(pow(1.0+nai/Knai,3.0)+pow(1.0+ki/Kki,2.0)-1.0);
x1=a4*a1*a2+b2*b4*b3+a2*b4*b3+b3*a1*a2;
x2=b2*b1*b4+a1*a2*a3+a3*b1*b4+a2*a3*b4;
x3=a2*a3*a4+b3*b2*b1+b2*b1*a4+a3*a4*b1;
x4=b4*b3*b2+a3*a4*a1+b2*a4*a1+b3*b2*a1;
E1=x1/(x1+x2+x3+x4);
E2=x2/(x1+x2+x3+x4);
E3=x3/(x1+x2+x3+x4);
E4=x4/(x1+x2+x3+x4);
double zk=1.0;
double JnakNa=3.0*(E1*a3-E2*b3);
double JnakK=2.0*(E4*b1-E3*a1);
double Pnak=30;
if (celltype==1)
{
    Pnak*=0.9;
}
if (celltype==2)
{
    Pnak*=0.7;
}
INaK=Pnak*(zna*JnakNa+zk*JnakK);

double xkb=1.0/(1.0+exp(-(v-14.48)/18.34));
double GKb=0.003;
IKb=GKb*xkb*(v-EK);

double PNab=3.75e-10;
INab=PNab*vffrt*(nai*exp(vfrt)-nao)/(exp(vfrt)-1.0);

double PCab=2.5e-8;
ICab=PCab*4.0*vffrt*(cai*exp(2.0*vfrt)-0.341*cao)/(exp(2.0*vfrt)-1.0);

double GpCa=0.0005;
IpCa=GpCa*cai/(0.0005+cai);
}

void FBC()
{
double CaMKb=CaMKo*(1.0-CaMKt)/(1.0+KmCaM/cass);
CaMKa=CaMKb+CaMKt;
CaMKt+=dt*(aCaMK*CaMKb*(CaMKb+CaMKt)-bCaMK*CaMKt);

JdiffNa=(nass-nai)/2.0;
JdiffK=(kss-ki)/2.0;
Jdiff=(cass-cai)/0.2;

double bt=4.75;
double a_rel=0.5*bt;
double Jrel_inf=a_rel*(-ICaL)/(1.0+pow(1.5/cajsr,8.0));
if (celltype==2)
{
Jrel_inf*=1.7;
}
double tau_rel=bt/(1.0+0.0123/cajsr);
if (tau_rel<0.005)
{
tau_rel=0.005;
}
Jrelnp=Jrel_inf-(Jrel_inf-Jrelnp)*exp(-dt/tau_rel);
double btp=1.25*bt;
double a_relp=0.5*btp;
double Jrel_infp=a_relp*(-ICaL)/(1.0+pow(1.5/cajsr,8.0));
if (celltype==2)
{
Jrel_infp*=1.7;
}
double tau_relp=btp/(1.0+0.0123/cajsr);
if (tau_relp<0.005)
{
tau_relp=0.005;
}
Jrelp=Jrel_infp-(Jrel_infp-Jrelp)*exp(-dt/tau_relp);
double fJrelp=(1.0/(1.0+KmCaMK/CaMKa));
Jrel=(1.0-fJrelp)*Jrelnp+fJrelp*Jrelp;
Jrel *= Jrel_ROS;

double Jupnp=0.004375*cai/(cai+0.00092);
double Jupp=2.75*0.004375*cai/(cai+0.00092-0.00017);
if (celltype==1)
{
Jupnp*=1.3;
Jupp*=1.3;
}
double fJupp=(1.0/(1.0+KmCaMK/CaMKa));
Jleak=0.0039375*cansr/15.0;
Jup=(1.0-fJupp)*Jupnp+fJupp*Jupp-Jleak;
Jup *= Jup_ROS;

Jtr=(cansr-cajsr)/100.0;

nai+=dt*(-(INa+INaL+3.0*INaCa_i+3.0*INaK+INab)*Acap/(F*vmyo)+JdiffNa*vss/vmyo);
nass+=dt*(-(ICaNa+3.0*INaCa_ss)*Acap/(F*vss)-JdiffNa);

ki+=dt*(-(Ito+IKr+IKs+IK1+IKb+Ist-2.0*INaK)*Acap/(F*vmyo)+JdiffK*vss/vmyo);
kss+=dt*(-(ICaK)*Acap/(F*vss)-JdiffK);

double Bcai;
if (celltype==1)
{
Bcai=1.0/(1.0+1.3*cmdnmax*kmcmdn/pow(kmcmdn+cai,2.0)+trpnmax*kmtrpn/pow(kmtrpn+cai,2.0));
}
else
{
Bcai=1.0/(1.0+cmdnmax*kmcmdn/pow(kmcmdn+cai,2.0)+trpnmax*kmtrpn/pow(kmtrpn+cai,2.0));
}
    cai+=dt*(Bcai*(-(IpCa+ICab-2.0*INaCa_i)*Acap/(2.0*F*vmyo)-Jup*vnsr/vmyo+Jdiff*vss/vmyo-V_uni*vmito/vmyo + V_mNaCa*vmito/vmyo-J_mPTP*vmito/vmyo));

double Bcass=1.0/(1.0+BSRmax*KmBSR/pow(KmBSR+cass,2.0)+BSLmax*KmBSL/pow(KmBSL+cass,2.0));
cass+=dt*(Bcass*(-(ICaL-2.0*INaCa_ss)*Acap/(2.0*F*vss)+Jrel*vjsr/vss-Jdiff));

cansr+=dt*(Jup-Jtr*vjsr/vnsr);

double Bcajsr=1.0/(1.0+csqnmax*kmcsqn/pow(kmcsqn+cajsr,2.0));
cajsr+=dt*(Bcajsr*(Jtr-Jrel));
}

void voltage()
{
v+=-dt*(INa+INaL+Ito+ICaL+ICaNa+ICaK+IKr+IKs+IK1+INaCa+INaK+INab+IKb+IpCa+ICab+Ist);
}

void stimulus()
{
if ((t>(start+n*CL) && t<(start+duration+n*CL-dt)))
	{
	if (Ist==0)
		{
		vrest=v;
		}
	Ist=amp;
	}
else if (t>(start+duration+n*CL-dt))
	{
	Ist=0.0;
	n=n+1;
	}
}

void dVdt_APD()
{
vdot_old=vdot;
vdot=(v-vo)/dt;
if (APD_flag==0 && v>-40 && vdot<vdot_old)
	{
	vdot_max=vdot_old;
	t_vdot_max=t-dt;
	APD_flag=1;
	}
if	(APD_flag==1 && v<0.9*vrest)
	{
	APD=t-t_vdot_max;
	APD_flag=0;
	}
}

void updateMitochondria() {



    double F_mito = 96.485; // mV-mmol/C
    double R_mito = 8.314; //mV-mmol/K

    // General Mitochondria Parameters
    double C_p = 1.8E-3; // mM/mV Mitochondrial inner membrane capacitance divided by F
    double a1 = 120.0; // Scaling factor between NADH consumption and change in membrane voltage
    double a2 = 3.43; // Scaling factor between ATP production by ATPase and change in membrane voltage
    double f_m = 0.01; // Fraction of free over buffer-bound Ca in mitochondria
    double NADm_tot = 2.970; // mM Total concentration of mitochondrial pyridine nucleotide


    double p_3 = 0.075; // /mV Voltage dependence coefficient of calcium leak
    double k_mPTP = 8.0E-6; // /ms Rate constant of bidirectional Ca leak from mitochondria

    //Cortassa Model Parameters
    //V_mNaCa
    double V_NaCa_max = 1.0E-4; //mM/ms
    double b = 0.5; //Psi dependence of NCX
    double deltaPsi0 = 91; //mV offset mem pot
    double K_Na = 9.4; //mM Antiporter Na+ constant
    double K_Ca = 3.75E-4; //mM antiporter Ca2+ constant
    double n = 3; //Na/Ca antiporter cooperativitiy

    //V_uni
    double V_uni_max = 0.0275; //mM/ms Vmax uniport Ca2+ transport
    double K_trans = 0.019; //mM Kd for translocated Ca2+
    double K_act = 3.8E-4; //mM Activation constant
    double L = 110; //Keq for conformational transitions in uniporter
    double n_a = 2.8; //uniporter activation cooperativity

    double delta = 3E-4; //fraction of free Ca2+m


    // Mitochondrial Metabolism Parameters
    double K_AGC = 0.14E-3; // mM Dissociation constant of Ca from AGC
    double p_4 = 0.01; // /mV Voltage dependence coefficient of AGC activity
    double q_1 = 0.2244; // Michaelis-Menten-like constant for NAD+ consumption by the Krebs cycle - Cortassa (S-22)
    double q_2 = 0.1E-3; // mM S0.5 value for activation of the Krebs cycle by Ca
    double V_AGC = 0.025E-3; // mM/ms Rate constant of NADH production via malate-aspartate shuttle
    double k_GLY = 4.5E-4; // mM/ms Velocity of glycolysis


    // Mitochondrial OXPHOS Parameters
    double q_3 = 100.0E-3; // mM Michaelis-Menten constant for NADH consumption by the ETC

    double q_4 = 177.0; // mV Voltage dependence coefficient 1 of ETC activity
    double q_5 = 5.0; // mV Voltage dependence coefficient 2 of ETC activity
    double q_6 = 10000.0E-3; // mM Inhibition constant of ATPase activity by ATP
    double q_7 = 190.0; // mV Voltage dependence coefficient of ATPase activity
    double q_8 = 8.5; // mV Voltage dependence coefficient of ATPase activity
    double q_9 = 0.0020E-3; // mM/ms*mV Voltage dependence of the proton leak
    double q_10 = -0.030E-3; // mM/ms Rate constant of the voltage-independent proton leak
    double V_ANT = 8.123E-3; // mM/ms Rate constant of the adenine nucleotide translocator
    double V_F1F0 = 3.6E-3; // mM/ms Rate constant of the F1FO ATPase
    double KATP = 3.5E-3; // mM
    double theta = 0.35; // ANT parameter
    double k_ETC = 0.764E-3; // mM/ms Rate constant of NADH oxidation by ETC - tuned


//Parameters from Table 1 ECME RIRR Model for ROS


    double RT_over_F    = 26.729246592691901;    //RToverF (mV)
    double NADPH = 1.0;       // (mM)        → from 1000 μM
    double b_ROS = 1.0E4; //no units Activation factor by cyto O2.-
    double Kcc = 0.01; //mM Activation constant of IMAC by O2.-
    double G_L = 7.82E-8; // (mM/msmV) Cortassa 2004
    double G_max = 7.82E-6; //(mM/msmV) Cortassa 2004
    double Kappa = 70E-3; // /mV steepness factor
    double Em_ROS = 4.0; //mV potential at half-saturation
    double k1_SOD = 1.2E3; //mM/ms Second-order rate consant of conversion btw native oxidized and reduced SOD
    double k3_SOD = 24; // /mM/ms Second-order rate consant of conversion btw native reduced SOD and its inactive form
    double k5_SOD = 0.25E-3; // /mM/ms First order rate constant for conversion btw inactive and active oxidized SOD
    double etSOD = 1.5E-3; //mM Intraceulluar concentration of SOD (range from 0.5E-3 to 2.5E-3)
    double Kki = 0.5; //mM Inhibition constant for H2O2
    double k1_CAT = 17.0; //mM-1 ms-1 Rate constant of CAT
    double EtCAT = 0.01; //mM Intraceullular CAT concentration
    double fr = 0.05; //no units hydrogen peroxide inhibition factor for CAT
    double EtGPX = 0.01; //mM intracellular GPX concentration
    double Phi1 = 0.5E-2; //mM*ms constant for GPX activity
    double Phi2 = 0.75; //mM*ms constant for GPX activity
    double k1_GR = 5.0E-3; //ms-1 rate consant of GR
    double EtGR = 0.01; //mM intracellular GR concentration
    double Km_GSSG = 0.06; //mM
    double Km_NADPH = 0.015; //mM
    double GT = 1.0; //mM (1-2 range)
    double j_Vt2SO2m = 0.1; //fraction of IMAC conductance


    double dCam, dPsi, dNADHm, dATPm, dADPm, NADm;
    double dROSm, dROSi, dH2O2, dGSH;



    V_uni = V_uni_max * (((cai / K_trans) * pow((1 + (cai / K_trans)), 3) * ((2 * F_mito) * (Psi - deltaPsi0) / (R_mito * T))) /(pow((1 + (cai / K_trans)), 4) + (L / pow((1 + (cai / K_act)), n_a)) * (1 - exp((-(2 * F_mito) * (Psi - deltaPsi0)) / (R_mito * T)))));


    V_mNaCa = V_NaCa_max * (exp((b * F_mito * (Psi - deltaPsi0) / (R_mito * T))) * std::log(cai / Cam)) / ((1 + pow(K_Na / nai, n)) * (1 + (K_Ca / Cam)));

    J_mPTP = (k_mPTP * (cai - Cam)) * exp(p_3 * Psi);

    J_PDH = k_GLY * (1 / (q_1 + (NADHm / (NADm_tot - NADHm)))) * (Cam / (q_2 + Cam));

    J_AGC = V_AGC * (cai / (K_AGC + cai)) * (q_2 / (q_2 + Cam)) * exp(p_4 * Psi);

    J_ETC = k_ETC * (NADHm / (q_3 + NADHm)) * (1 / (1 + exp((Psi - q_4) / q_5)));



    J_F1F0 = V_F1F0 * (q_6 / (q_6 + ATPm)) * (1 / (1 + exp((q_7 - Psi) / q_8)));

    J_ANT = V_ANT * ((ADP / (ADP + ATP * exp(-(theta * F_mito) * Psi / (R_mito * T)))) - (ADPm / (ADPm + ATPm * exp(((1 - theta) * F_mito) * Psi / (R_mito * T))))) * (1 / (1 + KATP / ADP));

    J_Hleak = q_9 * Psi + q_10;

    //ROS
    VIMAC2 = -1.0 * (1.0e-3 + b_ROS / (1.0 + Kcc / (ROSi))) * (G_L + G_max / ( 1 + exp(Kappa * (Em_ROS - (-1.0 * (Psi)))))) * (-1.0 * (Psi));

    Vt2SO2m = -j_Vt2SO2m * ( (-1.0 * (Psi) - RT_over_F * log((ROSm) / (ROSi))) / (Psi))
    * (-1 * (1.0e-3 + b_ROS / (1 + Kcc / (ROSi))) * (G_L + G_max / (1.0 + exp( Kappa * (Em_ROS - (-1.0 * (Psi)))))) * (-1.0 * (Psi)));

    VSOD = 2 * k1_SOD * k5_SOD * (k1_SOD + k3_SOD * (1 + (H2O2) / Kki)) * etSOD * (ROSi) / (k5_SOD * (2 * k1_SOD + k3_SOD * (1 + (H2O2) / Kki)) + k1_SOD * k3_SOD * (1 + (H2O2) / Kki) * (ROSi));

    VCAT = 2 * k1_CAT * EtCAT * exp(-fr * (H2O2)) * (H2O2);

    VGPX = EtGPX * (H2O2) * (GSH) / (Phi1 * (GSH) + Phi2 * (H2O2));



    VGR = k1_GR * EtGR / (1 + Km_GSSG / (0.5 * (GT - (GSH))) + Km_NADPH / NADPH + Km_GSSG * Km_NADPH / (0.5 * (GT - (GSH)) / NADPH));

    dCam = delta * (V_uni - V_mNaCa + J_mPTP);
    dNADHm = (J_PDH - J_ETC  + J_AGC);
    dADPm = J_ANT - J_F1F0;
    dATPm = J_F1F0 - J_ANT;
    dPsi = (a1 * J_ETC - a2 * J_F1F0 - J_ANT - J_Hleak - V_mNaCa - 2 * V_uni - 2 * J_mPTP - J_AGC) / C_p;


    dROSm = (ETC_Leak * J_ETC) - Vt2SO2m;
    dROSi = Vt2SO2m - VSOD;
    dH2O2 = VSOD - VCAT - VGPX;
    dGSH = VGR - VGPX;

    Cam += dCam * dt;
    NADHm += dNADHm * dt;
    ATPm += dATPm * dt;
    ADPm += dADPm * dt;
    Psi += dPsi * dt;

    // ROS
    ROSm += dROSm * dt;
    //ROSi += dROSi * dt;
    H2O2 += dH2O2 * dt;
    GSH  += dGSH  * dt;
}
