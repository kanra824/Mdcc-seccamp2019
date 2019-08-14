#include "mdcc.h"

Type *tyint() {
    Type *ty = calloc(1, sizeof(Type));
    ty->kind = INT;
    return ty;
}

Type *ptr_to(Type *base) {
    Type *ty = calloc(1, sizeof(ty));
    ty->kind = PTR;
    ty->ptr_to = base;
    return ty;
}

Type *tyfun() {
    Type *ty = calloc(1, sizeof(Type));
    ty->kind = FUN;
    return ty;
}

void tycheck(Node *node) {
    if(!node) return;

    tycheck(node->lhs);
    tycheck(node->rhs);
    int i = 0;
    while(node->children[i]) {
        tycheck(node->children[i]);
        i++;
    }

    switch(node->kind) {
    case ND_MUL:
    case ND_DIV:
    case ND_BEQ:
    case ND_NEQ:
    case ND_LT:
    case ND_LE:
    case ND_LVAR:
    case ND_APP:
    case ND_NUM:
        node->ty = tyint();
        return;
    case ND_ADD:
        if(node->rhs->ty->kind == PTR) {
            Node *tmp = node->lhs;
            node->lhs = node->rhs;
            node->rhs = tmp;
        }
        if(node->rhs->ty->kind == PTR) {
            error("invalid pointer arith");
        }
        node->ty = node->lhs->ty;
        return;
    case ND_SUB:
        if(node->rhs->ty->kind == PTR) {
            error("invalid pointer arith");
        }
        node->ty = node->lhs->ty;
        return;
    case ND_ASSIGN:
        node->ty = node->lhs->ty;
        return;
    case ND_ADDR:
        node->ty = ptr_to(node->lhs->ty);
        return;
    case ND_DEREF:
        if(node->ty->val == DEC) return;
        if(node->lhs->ty->kind == PTR) {
            node->ty = node->lhs->ty->ptr_to;
        } else {
            node->ty = tyint();
        }
        return;
    }


}

void tycheck_fun(Func *func) {
    func->ty = tyfun();
    int i = 0;
    while(func->children[i]) {
        tycheck(func->children[i]);
        i++;
    }
    return;
}