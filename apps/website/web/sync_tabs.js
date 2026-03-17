window.onload = () => {
  const tabs = (function() {
    const root = document.getElementById('__next') || document.querySelector('#root') || document.body;
    const key = Object.keys(root).find(k => k.startsWith('__reactContainer$') || k.startsWith('__reactFiber$'));
    if (!key) return;

    const queue = [root[key]];
    while (queue.length) {
      const f = queue.shift();
      
      // Check specific props on the component itself
      const p = f.memoizedProps ? f.memoizedProps.value : null;
      if (p && typeof p === 'object' && 'groups' in p && 'onChange' in p) {
        return f;
      }

      if (f.child) queue.push(f.child);
      if (f.sibling) queue.push(f.sibling);
    }
  })();
  
  const onChange = tabs.memoizedProps.value.onChange;
  const newOnChange = (id, value) => {
    onChange(id, value);

    if (id == 'mode') {
      const v =  value == 'client' ? 'client' : 'static|server';
      onChange('mode_combined', v);
      window.localStorage.setItem('docs.page:tabs:schultek/jaspr:mode_combined', v);
    } else if (id == 'mode_combined') {
      const v = value == 'client' ? 'client' : 'static';
      onChange('mode', v);
      window.localStorage.setItem('docs.page:tabs:schultek/jaspr:mode', v);
    }

    setTimeout(() => {
      tabs.memoizedProps.value.onChange = newOnChange;
    }, 10)
  }
  
  tabs.memoizedProps.value.onChange = newOnChange;
}