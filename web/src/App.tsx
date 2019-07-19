import * as React from 'react';

import Welcome from 'Welcome';

import 'App.less';
import fromLessModule from 'App.module.less';

class App extends React.Component {
    public render() {
        return (
            <div className="App">
                <header className="App-header">
                    <h1 className="App-title">
                        <Welcome>Welcome!!</Welcome>
                    </h1>
                    <div>
                        <p className="less-success">Style from Less</p>
                        <p className={fromLessModule.success}>Style from Less Modules</p>
                    </div>
                </header>
            </div>
        );
    }
}

export default App;
