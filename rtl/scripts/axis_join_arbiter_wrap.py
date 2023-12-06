#!/usr/bin/env python
"""
Generates an AXI Stream arbitrated mux wrapper with the specified number of ports
"""

import argparse
from jinja2 import Template


def main():
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('-p', '--ports',  type=int, default=3, help="number of ports")
    parser.add_argument('-n', '--name',   type=str, help="module name")
    parser.add_argument('-o', '--output', type=str, help="output file name")

    args = parser.parse_args()

    try:
        generate(**args.__dict__)
    except IOError as ex:
        print(ex)
        exit(1)


def generate(ports=4, name=None, output=None):
    n = ports

    if name is None:
        name = "axis_join_arbiter_wrap_{0}".format(n)

    if output is None:
        output = name + ".v"

    cn = (n-1).bit_length()

    t = Template(u"""

// Language: Verilog 2001

/*
 * AXI4-Stream {{n}} port join arbiter mux (wrapper)
 */
module {{name}} #
(
    parameter DATA_WIDTH = 64
)
(
    input  wire                     clk,
    input  wire                     rst,

    /*
     * AXI Stream inputs
     */
{%- for p in range(n) %}
    input  wire                   s{{'%02d'%p}}_axis_tvalid,
    input  wire [DATA_WIDTH-1:0]  s{{'%02d'%p}}_axis_tdata ,
    input  wire                   s{{'%02d'%p}}_axis_tlast ,
    output wire                   s{{'%02d'%p}}_axis_tready,
{% endfor %}
    /*
     * AXI Stream output
     */
    output wire                   m_axis_tvalid,
    output wire [DATA_WIDTH-1:0]  m_axis_tdata ,
    output wire                   m_axis_tlast ,
    input  wire                   m_axis_tready
);

axis_join_arbiter #(
    .S_COUNT({{n}}),
    .DATA_WIDTH(DATA_WIDTH)
)
axis_join_arbiter_inst (
    .clk(clk),
    .rst(rst),
    // AXI inputs
    .s_axis_tvalid({ {% for p in range(n-1,-1,-1) %}s{{'%02d'%p}}_axis_tvalid{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tdata({ {% for p in range(n-1,-1,-1) %}s{{'%02d'%p}}_axis_tdata{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tlast({ {% for p in range(n-1,-1,-1) %}s{{'%02d'%p}}_axis_tlast{% if not loop.last %}, {% endif %}{% endfor %} }),
    .s_axis_tready({ {% for p in range(n-1,-1,-1) %}s{{'%02d'%p}}_axis_tready{% if not loop.last %}, {% endif %}{% endfor %} }),
    // AXI output
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tready(m_axis_tready)
);

endmodule


""")

    print(f"Writing file '{output}'...")

    with open(output, 'w') as f:
        f.write(t.render(
            n=n,
            cn=cn,
            name=name
        ))
        f.flush()

    print("Done")


if __name__ == "__main__":
    main()
