#!/usr/bin/awk -f

function ttlesc(str)
{
	gsub(/\\/, "\\\\", str);
	gsub(/"/, "\\\"", str);
	return str;
}

@include "/data/data-source/onto/prefixes.awk"

BEGIN {
	FS = "|";
	OFS = "\t";

	REAL_ARGC = ARGC;
	for (i = 0; i < ARGC; i++) {
		if (ARGV[i] == "--help") {
			print "Usage: ttlify-new.awk [--since DATE] [--till DATE] FILE...";
			exit(0);
		} else if (ARGV[i] == "--date") {
			DATE = ARGV[i + 1];
			delete ARGV[i];
			delete ARGV[i + 1];
			REAL_ARGC -= 2;
		} else if (ARGV[i] == "--diff") {
			DIFF = 1;
			delete ARGV[i];
			REAL_ARGC--;
		}
	}
	if (REAL_ARGC <= 1) {
		ARGV[1] = "-";
		ARGC = 2;
	}

	print "@prefix bsym: <http://bsym.bloomberg.com/sym/> .";
	print "@prefix bps: <http://bsym.bloomberg.com/pricing_source/> .";
	print;

	mstbl["Comdty"] = "CommodityMarketSector";
	mstbl["Corp"] = "CorporateBondMarketSector";
	mstbl["Curncy"] = "CurrencyMarketSector";
	mstbl["Equity"] = "EquityMarketSector";
	mstbl["Govt"] = "GovernmentBondMarketSector";
	mstbl["Index"] = "IndexFundMarketSector";
	mstbl["M-Mkt"] = "MoneyMarketFundMarketSector";
	mstbl["Mtge"] = "MortgageMarketSector";
	mstbl["Muni"] = "MunicipalBondMarketSector";
	mstbl["Pfd"] = "PreferredStockMarketSector";

	typ["ABS Auto"] = "ABSAuto";
	typ["ABS Card"] = "ABSCard";
	typ["ABS Home"] = "ABSHome";
	typ["ABS Other"] = "ABSOther";
	typ["ADR"] = "ADR";
	typ["A/T Unit"] = "ATUnit";
	typ["ACCEPT BANCARIA"] = "AcceptBancaria";
	typ["ADJUSTABLE"] = "Adjustable";
	typ["ADJ CONV TO FIXED"] = "AdjustableConvertedToFixed";
	typ["ADJ CONV TO FIXED OID"] = "AdjustableConvertedToFixedOID";
	typ["ADJUSTABLE OID"] = "AdjustableOID";
	typ["Agncy ABS Home"] = "AgencyABSHome";
	typ["Agncy ABS Other"] = "AgencyABSOther";
	typ["Agncy CMO FLT"] = "AgencyCMOFloater";
	typ["Agncy CMO IO"] = "AgencyCMOInterestOnly";
	typ["Agncy CMO INV"] = "AgencyCMOInverse";
	typ["Agncy CMO Other"] = "AgencyCMOOther";
	typ["Agncy CMO PO"] = "AgencyCMOPrincipalOnly";
	typ["Agncy CMO Z"] = "AgencyCMOZBond";
	typ["ASSET BACK"] = "AssetBackedSecurity";
	typ["ASSET BASED BRIDGE"] = "AssetBasedBridge";
	typ["ASSET BASED BRIDGE REV"] = "AssetBasedBridgeRevolving";
	typ["ASSET BASED BRIDGE TERM"] = "AssetBasedBridgeTerm";
	typ["ASSET BASED COV-LITE DIP PIK"] = "AssetBasedCovenantLiteDIPPIK";
	typ["ASSET BASED COV-LITE REV"] = "AssetBasedCovenantLiteRevolving";
	typ["ASSET BASED DIP REV"] = "AssetBasedDIPRevolving";
	typ["ASSET BASED DIP TERM"] = "AssetBasedDIPTerm";
	typ["ASSET BASED DELAY-DRAW TERM"] = "AssetBasedDelayDrawTerm";
	typ["ASSET BASED LOC"] = "AssetBasedLOC";
	typ["ASSET BASED REV"] = "AssetBasedRevolving";
	typ["ASSET BACK REV FILO"] = "AssetBasedRevolvingFILO";
	typ["ASSET BASED TERM"] = "AssetBasedTerm";
	typ["AUSTRALIAN CD"] = "AustralianCD";
	typ["AUSTRALIAN CP"] = "AustralianCP";
	typ["AUSTRALIAN"] = "AustralianIssue";
	typ["Austrian Crt"] = "AustrianCertificate";
	typ["BANK ACCEPT BILL"] = "BankAcceptBill";
	typ["BANK NOTE"] = "BankNote";
	typ["BANKERS ACCEPT"] = "BankersAccept";
	typ["BANKERS ACCEPTANCE"] = "BankersAcceptance";
	typ["BASIS SWAP"] = "BasisSwap";
	typ["Basket WRT"] = "BasketWrt";
	typ["BDR"] = "Bdr";
	typ["BEARER DEP NOTE"] = "BearerDepNote";
	typ["Belgium Cert"] = "BelgiumCert";
	typ["BELGIUM CP"] = "BelgiumCp";
	typ["BILL OF EXCHANGE"] = "BillOfExchange";
	typ["Bond"] = "Bond";
	typ["BRAZILIAN CDI"] = "BrazilianCdi";
	typ["BRIDGE"] = "Bridge";
	typ["BRIDGE DELAY-DRAW TERM"] = "BridgeDelayDrawTerm";
	typ["BRIDGE ISLAMIC"] = "BridgeIslamic";
	typ["BRIDGE PIK"] = "BridgePik";
	typ["BRIDGE REV"] = "BridgeRev";
	typ["BRIDGE TERM"] = "BridgeTerm";
	typ["BULLDOG"] = "Bulldog";
	typ["BUTTERFLY SWAP"] = "ButterflySwap";
	typ["CAD INT BEAR CP"] = "CadIntBearCp";
	typ["Calendar Spread Option"] = "CalendarSpreadOption";
	typ["CALL LOANS"] = "CallLoans";
	typ["CANADIAN"] = "Canadian";
	typ["CANADIAN CD"] = "CanadianCD";
	typ["CANADIAN CP"] = "CanadianCP";
	typ["Canadian"] = "CanadianPool";
	typ["CAPS and FLOORS"] = "CapsAndFloors";
	typ["Car Forward"] = "CarForward";
	typ["CF"] = "CashFlow";
	typ["CBLO"] = "Cblo";
	typ["CD"] = "Cd";
	typ["CDR"] = "Cdr";
	typ["CDS Index"] = "CdsIndex";
	typ["Closed-End Fund"] = "ClosedEndFund";
	typ["CMBS"] = "Cmbs";
	typ["Cmdt Fut WRT"] = "CmdtFutWrt";
	typ["Cmdt Idx WRT"] = "CmdtIdxWrt";
	typ["COLLAT CALL NOTE"] = "CollatCallNote";
	typ["COMMERCIAL NOTE"] = "CommercialNote";
	typ["COMMERCIAL PAPER"] = "CommercialPaper";
	typ["Common Stock"] = "CommonStock";
	typ["CONTRACT FRA"] = "ContractFra";
	typ["Conv Bond"] = "ConvBond";
	typ["Conv Prfd"] = "ConvPrfd";
	typ["Corp Bnd WRT"] = "CorpBndWrt";
	typ["CP-LIKE EXT NOTE"] = "Cp-likeExtNote";
	typ["CPI LINKED"] = "CpiLinked";
	typ["CPI LINKED, OID"] = "CpiLinked,Oid";
	typ["CREDIT DEFAULT SWAP"] = "CreditDefaultSwap";
	typ["CROSS"] = "Cross";
	typ["Currency future."] = "CurrencyFuture";
	typ["Currency option."] = "CurrencyOption";
	typ["Currency spot"] = "CurrencySpot";
	typ["Currency WRT"] = "CurrencyWrt";
	typ["DELAY-DRAW"] = "DelayDraw";
	typ["DELAY-DRAW PIK TERM"] = "DelayDrawPikTerm";
	typ["DELAY-DRAW REV"] = "DelayDrawRev";
	typ["DELAY-DRAW TERM"] = "DelayDrawTerm";
	typ["DELAY-DRAW TERM MULTI-DRAW"] = "DelayDrawTermMultiDraw";
	typ["DELAY-DRAW VAT-TRNCH"] = "DelayDrawVatTrnch";
	typ["DEPOSIT"] = "Deposit";
	typ["DEPOSIT NOTE"] = "DepositNote";
	typ["DIP"] = "Dip";
	typ["DIP DELAY-DRAW TERM"] = "DipDelayDrawTerm";
	typ["DIP LOC"] = "DipLoc";
	typ["DIP PIK TERM"] = "DipPikTerm";
	typ["DIP REV"] = "DipRev";
	typ["DIP SYNTH LOC"] = "DipSynthLoc";
	typ["DIP TERM"] = "DipTerm";
	typ["DIP TERM MULTI-DRAW"] = "DipTermMultiDraw";
	typ["DISCOUNT FIXBIS"] = "DiscountFixbis";
	typ["DISCOUNT NOTES"] = "DiscountNotes";
	typ["DOMESTC TIME DEP"] = "DomestcTimeDep";
	typ["DOMESTIC"] = "Domestic";
	typ["DOMESTIC MTN"] = "DomesticMtn";
	typ["Dutch Cert"] = "DutchCert";
	typ["DUTCH CP"] = "DutchCp";
	typ["EDR"] = "Edr";
	typ["Equity Index"] = "EquityIndex";
	typ["Equity Option"] = "EquityOption";
	typ["Equity OTC Option"] = "EquityOtcOption";
	typ["Equity WRT"] = "EquityWrt";
	typ["EURO CD"] = "EuroCd";
	typ["EURO CP"] = "EuroCp";
	typ["EURO-DOLLAR"] = "EuroDollar";
	typ["EURO MTN"] = "EuroMtn";
	typ["EURO NON-DOLLAR"] = "EuroNonDollar";
	typ["EURO STRUCTRD LN"] = "EuroStructrdLn";
	typ["EURO TIME DEPST"] = "EuroTimeDepst";
	typ["EURO-ZONE"] = "Eurozone";
	typ["ETF"] = "ExchangeTradedFund";
	typ["ETP"] = "ExchangeTradedProduct";
	typ["EXTEND COMM NOTE"] = "ExtendibleCommercialNote";
	typ["EXTEND. NOTE MTN"] = "ExtendibleNoteMTN";
	typ["FDIC"] = "FDIC";
	typ["FED FUNDS"] = "FedFunds";
	typ["FED NOON BUYING RATE"] = "FedNoonBuyingRate";
	typ["FIDC"] = "Fidc";
	typ["Financial commodity future."] = "FinancialCommodityFuture";
	typ["Financial commodity generic."] = "FinancialCommodityGeneric";
	typ["Financial commodity option."] = "FinancialCommodityOption";
	typ["Financial commodity spot."] = "FinancialCommoditySpot";
	typ["Financial index future."] = "FinancialIndexFuture";
	typ["Financial index option."] = "FinancialIndexOption";
	typ["FINNISH CD"] = "FinnishCd";
	typ["FINNISH CP"] = "FinnishCp";
	typ["FIXED"] = "FixedRate";
	typ["FIXED, OID"] = "FixedRateOID";
	typ["FIXING RATE"] = "FixingRate";
	typ["FLOATING CP"] = "FloatingCp";
	typ["FLOATING"] = "FloatingRate";
	typ["FLOATING, OID"] = "FloatingRateOID";
	typ["FORWARD"] = "Forward";
	typ["FORWARD CROSS"] = "ForwardCross";
	typ["FORWARD CURVE"] = "ForwardCurve";
	typ["FRA"] = "Fra";
	typ["FRENCH CD"] = "FrenchCd";
	typ["French Cert"] = "FrenchCert";
	typ["FRENCH CP"] = "FrenchCp";
	typ["Fund of Funds"] = "FundOfFunds";
	typ["FUTURE"] = "Future";
	typ["FWD SWAP"] = "FwdSwap";
	typ["FX DISCOUNT NOTE"] = "FxDiscountNote";
	typ["GDR"] = "Gdr";
	typ["Generic currency future."] = "GenericCurrencyFuture";
	typ["Generic index future."] = "GenericIndexFuture";
	typ["German Cert"] = "GermanCert";
	typ["GERMAN CP"] = "GermanCp";
	typ["GLOBAL"] = "Global";
	typ["GUARANTEE FAC"] = "GuaranteeFac";
	typ["Hedge Fund"] = "HedgeFund";
	typ["HONG KONG CD"] = "HongKongCd";
	typ["HB"] = "HybridSecurityType";
	typ["IDR"] = "Idr";
	typ["IMM FORWARDS"] = "ImmForwards";
	typ["IMM SWAP"] = "ImmSwap";
	typ["Index Option"] = "IndexOption";
	typ["Index OTC Option"] = "IndexOtcOption";
	typ["Index WRT"] = "IndexWrt";
	typ["INDIAN CD"] = "IndianCd";
	typ["INDIAN CP"] = "IndianCp";
	typ["INDONESIAN CP"] = "IndonesianCp";
	typ["Indx Fut WRT"] = "IndxFutWrt";
	typ["INFLATION SWAP"] = "InflationSwap";
	typ["INT BEAR FIXBIS"] = "IntBearFixbis";
	typ["INTERBANK OFFERED RATE"] = "InterbankOfferedRate";
	typ["INTER. APPRECIATION"] = "InterestAppreciation";
	typ["INTER. APPRECIATION, OID"] = "InterestAppreciationOID";
	typ["INTEREST RATE GUARANTEE"] = "InterestRateGuarantee";
	typ["Int. Rt. WRT"] = "InterestRateWarrant";
	typ["I.R. Fut WRT"] = "IrFutWrt";
	typ["I.R. Swp WRT"] = "IrSwpWrt";
	typ["ISLAMIC"] = "Islamic";
	typ["ISLAMIC BA"] = "IslamicBa";
	typ["ISLAMIC CP"] = "IslamicCp";
	typ["ISLAMIC LOC"] = "IslamicLoc";
	typ["ISLAMIC REV"] = "IslamicRev";
	typ["ISLAMIC STANDBY"] = "IslamicStandby";
	typ["ISLAMIC STANDBY REV"] = "IslamicStandbyRev";
	typ["ISLAMIC TERM"] = "IslamicTerm";
	typ["JUMBO CD"] = "JumboCd";
	typ["KOREAN CD"] = "KoreanCd";
	typ["KOREAN CP"] = "KoreanCp";
	typ["LEBANESE CP"] = "LebaneseCp";
	typ["LIQUIDITY NOTE"] = "LiquidityNote";
	typ["LOC"] = "Loc";
	typ["Ltd Part"] = "LtdPart";
	typ["MALAYSIAN CP"] = "MalaysianCp";
	typ["MARGIN TERM DEP"] = "MarginTermDep";
	typ["MV"] = "MarketValue";
	typ["MASTER NOTES"] = "MasterNote";
	typ["MBS 10yr"] = "Mbs10yr";
	typ["MBS 15yr"] = "Mbs15yr";
	typ["MBS 20yr"] = "Mbs20yr";
	typ["MBS 30yr"] = "Mbs30yr";
	typ["MBS ARM"] = "MbsArm";
	typ["MBS balloon"] = "MbsBalloon";
	typ["MBS Other"] = "MbsOther";
	typ["MED TERM NOTE"] = "MedTermNote";
	typ["MEDIUM TERM CD"] = "MediumTermCd";
	typ["MEDIUM TERM ECD"] = "MediumTermEcd";
	typ["MEDIUM TERM YCD"] = "MediumTermYcd";
	typ["MEXICAN CP"] = "MexicanCp";
	typ["MEXICAN PAGARE"] = "MexicanPagare";
	typ["Misc."] = "Miscellaneous";
	typ["MLP"] = "Mlp";
	typ["MONEY MARKET CALL"] = "MoneyMarketCall";
	typ["MTN SUBORDINATED"] = "MtnSubordinated";
	typ["MUNI CP"] = "MuniCp";
	typ["MUNI INT BEAR CP"] = "MuniIntBearCp";
	typ["MUNI SWAP"] = "MuniSwap";
	typ["MURABAHA"] = "Murabaha";
	typ["Mutual Fund"] = "MutualFund";
	typ["MX CERT BURSATIL"] = "MxCertBursatil";
	typ["NDF FIXING"] = "NdfFixing";
	typ["NDF SWAP"] = "NdfSwap";
	typ["NEG INST DEPOSIT"] = "NegInstDeposit";
	typ["NEGOTIABLE CD"] = "NegotiableCd";
	typ["NEW ZEALAND CP"] = "NewZealandCp";
	typ["NON-DELIVERABLE FORWARD"] = "NonDeliverableForward";
	typ["NON-DELIVERABLE IRS SWAP"] = "NonDeliverableIrsSwap";
	typ["NON-DELIVERABLE OIS SWAP"] = "NonDeliverableOisSwap";
	typ["Non-Equity Index"] = "NonEquityIndex";
	typ["NORWEGIAN CD"] = "NorwegianCd";
	typ["NY Reg Shrs"] = "NyRegShrs";
	typ["OID"] = "Oid";
	typ["ONSHORE FORWARD"] = "OnshoreForward";
	typ["ONSHORE SWAP"] = "OnshoreSwap";
	typ["Open-End Fund"] = "OpenEndFund";
	typ["OPTION"] = "Option";
	typ["OPTION VOLATILITY"] = "OptionVolatility";
	typ["OTC Option"] = "OtcOption";
	typ["OTHER"] = "Other";
	typ["OVER/NIGHT"] = "OverNight";
	typ["OVERDRAFT"] = "Overdraft";
	typ["OVERNIGHT INDEXED SWAP"] = "OvernightIndexedSwap";
	typ["PHILIPPINE CP"] = "PhilippineCp";
	typ["Physical commodity forward."] = "PhysicalCommodityForward";
	typ["Physical commodity future."] = "PhysicalCommodityFuture";
	typ["Physical commodity generic."] = "PhysicalCommodityGeneric";
	typ["Physical commodity option."] = "PhysicalCommodityOption";
	typ["Physical commodity spot."] = "PhysicalCommoditySpot";
	typ["Physical index future."] = "PhysicalIndexFuture";
	typ["Physical index option."] = "PhysicalIndexOption";
	typ["PIK"] = "Pik";
	typ["PIK REVOLVER"] = "PikRev";
	typ["PIK STANDBY TERM"] = "PikStandbyTerm";
	typ["PIK TERM"] = "PikTerm";
	typ["PLAZOS FIJOS"] = "PlazosFijos";
	typ["PORTUGUESE CP"] = "PortugueseCp";
	typ["Preference"] = "Preference";
	typ["Preferred"] = "Preferred";
	typ["Prfd WRT"] = "PrfdWrt";
	typ["PRIV PLACEMENT"] = "PrivPlacement";
	typ["PRIVATE"] = "Private";
	typ["Private Comp"] = "PrivateComp";
	typ["Private Eqty"] = "PrivateEqty";
	typ["PROMISSORY NOTE"] = "PromissoryNote";
	typ["PROPERTY SWAP"] = "PropertySwap";
	typ["PROV T-BILL"] = "ProvTBill";
	typ["Prvt CMO FLT"] = "PrvtCmoFlt";
	typ["Prvt CMO INV"] = "PrvtCmoInv";
	typ["Prvt CMO IO"] = "PrvtCmoIo";
	typ["Prvt CMO Other"] = "PrvtCmoOther";
	typ["Prvt CMO PO"] = "PrvtCmoPo";
	typ["Prvt CMO Z"] = "PrvtCmoZ";
	typ["PUBLIC"] = "Public";
	typ["Pvt Eqty Fund"] = "PvtEqtyFund";
	typ["QUARTERLY SWAP"] = "QuarterlySwap";
	typ["RDC"] = "Rdc";
	typ["Receipt"] = "Receipt";
	typ["REIT"] = "Reit";
	typ["REPO"] = "Repo";
	typ["RESTRUCTURD DEBT"] = "RestructurdDebt";
	typ["RETAIL CD"] = "RetailCd";
	typ["RETURN IDX"] = "ReturnIdx";
	typ["REV"] = "Rev";
	typ["REV GUARANTEE FAC"] = "RevGuaranteeFac";
	typ["REV VAT-TRNCH"] = "RevVatTrnch";
	typ["Right"] = "Right";
	typ["Royalty Trst"] = "RoyaltyTrst";
	typ["S/A MD TERM YCD"] = "SAMdTermYcd";
	typ["SAMURAI"] = "Samurai";
	typ["Savings Plan"] = "SavingsPlan";
	typ["SBA Pool"] = "SbaPool";
	typ["Sec Lending"] = "SecLending";
	typ["2ND LIEN"] = "SecondLien";
	typ["SEMI-ANNUAL SWAP"] = "SemiAnnualSwap";
	typ["SHOGUN"] = "Shogun";
	typ["SHORT TERM BN"] = "ShortTermBn";
	typ["SHORT TERM DN"] = "ShortTermDn";
	typ["S.TERM LOAN NOTE"] = "ShortTermLoanNote";
	typ["SINGAPORE CP"] = "SingaporeCp";
	typ["SINGLE STOCK FUTURE"] = "SingleStockFuture";
	typ["SPARE - N/A"] = "SpareNa";
	typ["SPOT"] = "Spot";
	typ["Spot index."] = "SpotIndex";
	typ["STANDBY"] = "Standby";
	typ["STANDBY LOC"] = "StandbyLoc";
	typ["STANDBY REV"] = "StandbyRev";
	typ["STANDBY TERM"] = "StandbyTerm";
	typ["STERLING CD"] = "SterlingCd";
	typ["STERLING CP"] = "SterlingCp";
	typ["Strategy Trade."] = "StrategyTrade";
	typ["SN"] = "StructuredNote";
	typ["SWAP"] = "Swap";
	typ["SWAP SPREAD"] = "SwapSpread";
	typ["SWAPTION VOLATILITY"] = "SwaptionVolatility";
	typ["SWEDISH CP"] = "SwedishCp";
	typ["SWING LINE LOAN"] = "SwingLineLoan";
	typ["SWINGLINE"] = "Swingline";
	typ["Swiss Cert"] = "SwissCert";
	typ["SYNTH"] = "Synth";
	typ["SYNTH LOC"] = "SynthLoc";
	typ["SYNTH REV"] = "SynthRev";
	typ["SYNTH TERM"] = "SynthTerm";
	typ["TAIWAN CP"] = "TaiwanCp";
	typ["TAIWAN CP GUAR"] = "TaiwanCpGuar";
	typ["TAIWAN NEGO CD"] = "TaiwanNegoCd";
	typ["TAIWAN TIME DEPO"] = "TaiwanTimeDepo";
	typ["TAX CREDIT"] = "TaxCredit";
	typ["TAX CREDIT, OID"] = "TaxCreditOid";
	typ["TERM"] = "Term";
	typ["TERM DEPOSITS"] = "TermDeposits";
	typ["TERM MULTI-DRAW"] = "TermMultiDraw";
	typ["TERM OVERDRAFT"] = "TermOverdraft";
	typ["TERM VAT-TRNCH"] = "TermVatTrnch";
	typ["THAILAND CP"] = "ThailandCp";
	typ["Tracking Stk"] = "TrackingStk";
	typ["UIT"] = "Uit";
	typ["UK GILT STOCK"] = "UkGiltStock";
	typ["Unit"] = "Unit";
	typ["Unit Inv Tst"] = "UnitInvTst";
	typ["U.S. CD"] = "UsCd";
	typ["U.S. CP"] = "UsCp";
	typ["US DOMESTIC"] = "UsDomestic";
	typ["US GOVERNMENT"] = "UsGovernment";
	typ["U.S. INT BEAR CP"] = "UsIntBearCp";
	typ["US NON-DOLLAR"] = "UsNonDollar";
	typ["VAR RATE DEM OBL"] = "VarRateDemObl";
	typ["Variable Annuity"] = "VariableAnnuity";
	typ["VAT-TRNCH"] = "VatTrnch";
	typ["VENEZUELAN CP"] = "VenezuelanCp";
	typ["VOLATILITY DERIVATIVE"] = "VolatilityDerivative";
	typ["WARRANT"] = "Warrant";
	typ["WHEN ISSUED"] = "WhenIssued";
	typ["WHEN ISSUED, OID"] = "WhenIssuedOid";
	typ["YANKEE"] = "Yankee";
	typ["YANKEE CD"] = "YankeeCd";
	typ["YEN CD"] = "YenCd";
	typ["YEN CP"] = "YenCp";
	typ["ZERO COUPON"] = "ZeroCoupon";
	typ["ZERO COUPON, OID"] = "ZeroCouponOid";

	mon["Jan"] = 1;
	mon["Feb"] = 2;
	mon["Mar"] = 3;
	mon["Apr"] = 4;
	mon["May"] = 5;
	mon["Jun"] = 6;
	mon["Jul"] = 7;
	mon["Aug"] = 8;
	mon["Sep"] = 9;
	mon["Oct"] = 10;
	mon["Nov"] = 11;
	mon["Dec"] = 12;
}
/TIMESTARTED=/ {
	if (!DATE) {
		d = gensub(/^TIMESTARTED=... (...) (..) ..:..:.. ... (....)$/, "\\3-\\1-\\2", "g");
		split(d, a, "-");
		date = sprintf("%04u-%02u-%02u", a[1], mon[a[2]], a[3]);
	} else {
		date = DATE;
	}
}
(NF >= 11 && $10 && $11) {
	figi = $4;
	ftyp = $8;
	mkts = $9;
	tick = $10;
	name = $11;
	if ($7 != tick " " mkts && length($7) > length(tick)) {
		## maybe that's the better tick?
		tick = $7;
	}
	if (mkts == "Equity" && $13 ~ /BBG........./) {
		comp = $13;
	}
	exch = $19;
	if (mkts == "Equity" && $20 ~ /BBG........./) {
		shcl = $20;
	}

	if ($2 < 0) {
		print "bsym:" $4, "gas:listedTill", "\"" date "\"^^xsd:date .";
		next;
	}
	## otherwise
	if (0) {
	} else if (figi == shcl) {
		print "bsym:" figi, "a", "figi-gii:ShareClassGlobalIdentifier ;";
	} else if (figi == comp) {
		print "bsym:" figi, "a", "figi-gii:CompositeGlobalIdentifier ;";
		if (shcl) {
			print "", "gas:componentOf", "bsym:" shcl " ;";
		}
	} else {
		print "bsym:" figi, "a", "figi-gii:GlobalIdentifier ;";

		if (comp) {
			print "", "gas:componentOf", "bsym:" comp " ;";
		}
	}
	print "", "gas:sector", "figi-gii:" mstbl[mkts] " ;";
	print "", "foaf:name", "\"" ttlesc(name) "\" ;";
	if (exch) {
		print "", "gas:listedOn", "bps:" exch " ;";
	}
	print "", "gas:listedAs", "\"" ttlesc(tick) "\" ;";
	if (typ[ftyp]) {
		print "", "gas:securityType", "figi-typ:" typ[ftyp] " ;";
	}
	if (DIFF) {
		print "", "gas:listedSince", "\"" date "\"^^xsd:date ;"
	}
	print "", "gas:symbolOf", "bsym: , <http://www.bloomberg.com/> .";
	if (shcl && figi != shcl) {
		print "bsym:" shcl, "a", "figi-gii:ShareClassGlobalIdentifier ;";
		print "", "gas:symbolOf", "bsym: , <http://www.bloomberg.com/> .";
	}
	if (comp && figi != comp) {
		print "bsym:" comp, "a", "figi-gii:CompositeGlobalIdentifier ;";
		print "", "gas:symbolOf", "bsym: , <http://www.bloomberg.com/> .";
	}
}
