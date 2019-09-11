import dxpyfeed as dxp
import pandas as pd

import dash
import dash_core_components as dcc
import dash_html_components as html
import plotly
from dash.dependencies import Input, Output
import plotly.graph_objects as go

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
symbol = 'IBM'

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
app.layout = html.Div(
    html.Div([
        html.H4(f'Quotes for {symbol}'),
        dcc.Graph(id='live-update-graph'),
        dcc.Interval(
            id='interval-component',
            interval=1*100, # in milliseconds
            n_intervals=0
        )
    ])
)

con = dxp.dxf_create_connection('mddqa.in.devexperts.com:7400')
sub = dxp.dxf_create_subscription(con, 'Quote', data_len=200)
dxp.dxf_add_symbols(sub, [symbol])
dxp.dxf_attach_listener(sub)


# Multiple components can update everytime interval gets fired.
@app.callback(Output('live-update-graph', 'figure'),
              [Input('interval-component', 'n_intervals')])
def update_graph_live(n):
    df = sub.to_data_frame()
    df.loc[:, 'Time'] = df.BidTime.combine_first(df.AskTime)
    df = df.ffill().bfill()
    df.loc[:, 'MarkPrice'] = (df.AskPrice.values + df.BidPrice.values) / 2

    return {
        'data': [
            # Bid
            go.Scatter(
                x=df.Time,
                y=df.BidPrice,
                text=df.Symbol,
                mode='lines',
                name='Bid'
            ),
            # Ask
            go.Scatter(
                x=df.Time,
                y=df.AskPrice,
                text=df.Symbol,
                mode='lines',
                name='Ask'
            ),
            # Mark
            go.Scatter(
                x=df.Time,
                y=df.MarkPrice,
                text=df.Symbol,
                mode='lines',
                name='Mark'
            )
        ],
        'layout': go.Layout(
            xaxis={
                'title': 'Time',
            },
            yaxis={
                'title': 'US Dollars',
            },
            margin={'l': 100, 'b': 100, 't': 10, 'r': 0},
            height=450,
            hovermode='closest'
        )
    }


if __name__ == '__main__':
    app.run_server(debug=True, port=8060)
