#include "Unary.h"
#include "SynTreeException.h"

Unary::Unary(SynNode * p_next, Operator * p_operator, int line): Expr(line, SynNode::UNARY)
{
    this->p_next_ = p_next;
    this->p_next_->set_prev(this);
    this->p_operator_ = p_operator;
}

// 输出用于产生图的dot文件
void Unary::gen_graph(std::ofstream * p_fout) const
{
    Expr::gen_graph(p_fout);
    this->p_next_->gen_graph(p_fout);
}

const Terminal * Unary::gen_ir(int label_in, int label_out, QuadTable * p_quad_table) const
{
    const Terminal * ret_terminal;  // 子节点返回对象
    std::string arg, result;  // 输出到四元式的字符串

    // 因为单目运算符不会发生用于短路求值的跳转，因此可以直接赋值不用根据Operator判断
    ret_terminal = this->p_next_->gen_ir(label_in, label_out, p_quad_table);
    arg = ret_terminal->to_string();
    result = Expr::get_temp_variable()->to_string();
    // 根据运算符类型决定产生四元式类型
    switch (this->p_operator_->get_type())
    {
        case Operator::UNARY_NOT:
            // 这个比较复杂，翻译结果类似if(a == 0) t = 1; else t = 0;
            // long label[3];
            // for (int i = 0; i < 3; i++)
            //     label[i] = SynNode::get_new_label();
            // p_quad_table->add("JZ", arg, "", "L" + std::to_string(label[0]));
            // p_quad_table->add("J", "", "", "L" + std::to_string(label[1]));
            // p_quad_table->add_label(label[0]);
            // p_quad_table->add("=", "1", "", result);
            // p_quad_table->add("J", "", "", "L" + std::to_string(label[2]));
            // p_quad_table->add_label(label[1]);
            // p_quad_table->add("=", "0", "", result);
            // p_quad_table->add_label(label[2]);
            Expr::quad_if_else(arg, "", result, "JZ", p_quad_table);
            break;
        case Operator::UNARY_MINUS:
            // 将负数变为0 - 数
            p_quad_table->add("-", "0", arg, (Expr::get_temp_variable())->to_string());
            break;
        case Operator::UNARY_ADDRESS:
            throw new SynTreeException("Unsupported address operator &");
            break;
        case Operator::UNARY_INDIRECTION:
            throw new SynTreeException("Unsupported indirection operator *");
            break;
        case Operator::UNARY_INCR:
            // 将++自增变为+1
            p_quad_table->add("+", arg, "1", (Expr::get_temp_variable())->to_string());
            break;
        case Operator::UNARY_DECR:
            // 将--自减变为-1
            p_quad_table->add("-", arg, "1", (Expr::get_temp_variable())->to_string());
            break;
        default:
            throw new SynTreeException("Illegal unary operator");
            break;
    }

    return Expr::get_temp_variable();
}

// 被emit_node()调用，返回可以在图中以文字显示的节点内容
std::string Unary::get_node_content() const
{
    return this->p_operator_->to_string();
}