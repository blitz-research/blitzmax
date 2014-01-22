
#ifndef CGCODE_H
#define CGCODE_H

//calling conventions
enum{
	CG_CDECL=1,
	CG_STDCALL=2
};

//data types
enum{
	CG_VOID=-1,
	CG_PTR,
	CG_INT8,CG_INT16,
	CG_INT32,CG_INT64,
	CG_FLOAT32,CG_FLOAT64,
	CG_CSTRING,CG_BSTRING,CG_BINFILE,CG_LABEL
};

//condition codes
enum{
	CG_EQ,CG_NE,
	CG_LT,CG_GT,CG_LE,CG_GE,
	CG_LTU,CG_GTU,CG_LEU,CG_GEU
};

//unary operators for cguop
enum{
	CG_NEG,CG_NOT,CG_ABS,CG_SGN
};

//binary operators for cgbop
enum{
	CG_ADD,CG_SUB,CG_MUL,CG_DIV,CG_MOD,
	CG_AND,CG_ORL,CG_XOR,CG_SHL,CG_SHR,CG_SAR,
	CG_MIN,CG_MAX
};

//linkage flags
enum{
	CG_INTERNAL,CG_IMPORT,CG_EXPORT
};

//statements
struct CGStm;
struct CGNop;
struct CGXop;
struct CGRem;
struct CGAti;
struct CGAtd;
struct CGMov;
struct CGLab;
struct CGBra;
struct CGBcc;
struct CGEva;
struct CGRet;
struct CGSeq;

//expressions
struct CGExp;
struct CGMem;
struct CGLea;
struct CGCvt;
struct CGUop;
struct CGBop;
struct CGJsr;
struct CGVfn;
struct CGScc;
struct CGEsq;
//leaf expressions
struct CGFrm;
struct CGTmp;
struct CGLit;
struct CGSym;
struct CGDat;
//private!
struct CGReg;

struct CGVisitor{
	virtual CGStm *visit( CGStm *stm );
	virtual CGExp *visit( CGExp *exp );
};

struct CGStm{
	virtual ~CGStm()=0;

	virtual CGNop *nop();
	virtual CGXop *xop();
	virtual CGRem *rem();
	virtual CGAti *ati();
	virtual CGAtd *atd();
	virtual CGMov *mov();
	virtual CGLab *lab();
	virtual CGBra *bra();
	virtual CGBcc *bcc();
	virtual CGEva *eva();
	virtual CGRet *ret();
	virtual CGSeq *seq();

	virtual CGStm *visit( CGVisitor &vis );
};

typedef std::vector<CGStm*> CGStmSeq;

struct CGExp{
	int type;

	virtual ~CGExp()=0;

	virtual CGMem *mem();
	virtual CGLea *lea();
	virtual CGCvt *cvt();
	virtual CGUop *uop();
	virtual CGBop *bop();
	virtual CGJsr *jsr();
	virtual CGVfn *vfn();
	virtual CGScc *scc();
	virtual CGEsq *esq();
	virtual CGFrm *frm();
	virtual CGTmp *tmp();
	virtual CGLit *lit();
	virtual CGSym *sym();
	virtual CGDat *dat();
	virtual CGReg *reg();
	
	virtual CGExp *nonEsq();

	virtual bool sideEffects();
	virtual bool equals( CGExp *exp );
	virtual CGExp *visit( CGVisitor &vis );

	bool	isint(){ return !isfloat(); }
	bool	isfloat(){ return type==CG_FLOAT32||type==CG_FLOAT64; }
};

struct CGNop : public CGStm{

	CGNop *nop();
	
	CGStm *visit( CGVisitor &vis );
};

struct CGXop : public CGStm{
	int op;
	CGReg *def;
	CGExp *exp;

	CGXop *xop();

	CGStm *visit( CGVisitor &vis );
};

struct CGRem : public CGStm{
	string comment;

	CGRem *rem();
	
	CGStm *visit( CGVisitor &vis );
};

struct CGAti : public CGStm{
	CGMem *mem;

	CGAti *ati();

	CGStm *visit( CGVisitor &vis );
};

struct CGAtd : public CGStm{
	CGMem *mem;
	CGSym *sym;

	CGAtd *atd();

	CGStm *visit( CGVisitor &vis );
};

struct CGMov : public CGStm{
	CGExp *lhs,*rhs;

	CGMov *mov();

	CGStm *visit( CGVisitor &vis );
};

struct CGLab : public CGStm{
	CGSym *sym;

	CGLab *lab();

	CGStm *visit( CGVisitor &vis );
};

struct CGBra : public CGStm{
	CGSym *sym;

	CGBra *bra();

	CGStm *visit( CGVisitor &vis );
};

struct CGBcc : public CGStm{
	int cc;
	CGExp *lhs,*rhs;
	CGSym *sym;

	CGBcc *bcc();

	CGStm *visit( CGVisitor &vis );
};

struct CGEva : public CGStm{
	CGExp *exp;

	CGEva *eva();

	CGStm *visit( CGVisitor &vis );
};

struct CGRet : public CGStm{
	CGExp *exp;

	CGRet *ret();

	CGStm *visit( CGVisitor &vis );
};

struct CGSeq : public CGStm{
	vector<CGStm*> stms;

	CGSeq *seq();

	CGStm *visit( CGVisitor &vis );
	
	void push_back( CGStm *stm );
	void push_front( CGStm *stm );
};

struct CGMem : public CGExp{
	CGExp *exp;
	int offset,flags;

	CGMem *mem();

	bool sideEffects();
	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGLea : public CGExp{
	CGExp *exp;

	CGLea *lea();

	bool sideEffects();
	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGCvt : public CGExp{
	CGExp *exp;

	CGCvt *cvt();

	bool sideEffects();
	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGUop : public CGExp{
	int op;
	CGExp *exp;

	CGUop *uop();

	bool sideEffects();
	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGBop : public CGExp{
	int op;
	CGExp *lhs,*rhs;

	CGBop *bop();

	bool commutes();

	bool sideEffects();
	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGJsr : public CGExp{
	int call_conv;
	CGExp *exp;
	std::vector<CGExp*> args;

	CGJsr *jsr();

	bool sideEffects();
	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGVfn : public CGExp{
	CGExp *exp,*self;

	CGVfn *vfn();

	bool sideEffects();
	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGScc : public CGExp{
	int cc;
	CGExp *lhs,*rhs;

	CGScc *scc();

	bool sideEffects();
	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGEsq : public CGExp{
	CGStm *lhs;
	CGExp *rhs;

	CGEsq *esq();

	CGExp *nonEsq();

	bool sideEffects();
	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGFrm : public CGExp{
	CGFrm *frm();
	
	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGTmp : public CGExp{
	string ident;
	CGTmp *owner;

	CGTmp *tmp();

	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGReg : public CGExp{
	int id,color;
	CGReg *owner;

	CGReg *reg();

	bool equals( CGExp *e );
	CGExp *visit( CGVisitor &vis );
};

struct CGLit : public CGExp{
	int64 int_value;
	double float_value;
	bstring string_value;

	CGLit *lit();

	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGSym : public CGExp{
	string value;
	int linkage;

	CGSym *sym();

	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
};

struct CGDat : public CGSym{
	std::vector<CGExp*> exps;

	CGDat *dat();

	bool equals( CGExp *exp );
	CGExp *visit( CGVisitor &vis );
	
	void push_back( CGExp *exp );
};

struct CGFun : public CGExp{
	int call_conv;
	CGSym *sym;
	CGExp *self;
	std::vector<CGExp*> args;
	std::vector<CGStm*> stms;
};

#endif
