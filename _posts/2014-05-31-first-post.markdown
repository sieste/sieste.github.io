---
title: Hello world
layout: default
---

## The first post

with a bit of text and [a link](http://sieste.github.io)


```cpp
typedef struct ITaskbarListVtbl
{
	BEGIN_INTERFACE

	HRESULT ( STDMETHODCALLTYPE *QueryInterface )(
		__RPC__in ITaskbarList * This,
		/* [in] */ __RPC__in REFIID riid,
		/* [annotation][iid_is][out] */
		__RPC__deref_out  void **ppvObject);

	ULONG ( STDMETHODCALLTYPE *AddRef )(
		__RPC__in ITaskbarList * This);

	ULONG ( STDMETHODCALLTYPE *Release )(
		__RPC__in ITaskbarList * This);

	HRESULT ( STDMETHODCALLTYPE *HrInit )(
		__RPC__in ITaskbarList * This);

	HRESULT ( STDMETHODCALLTYPE *AddTab )(
		__RPC__in ITaskbarList * This,
		/* [in] */ __RPC__in HWND hwnd);

	HRESULT ( STDMETHODCALLTYPE *DeleteTab )(
		__RPC__in ITaskbarList * This,
		/* [in] */ __RPC__in HWND hwnd);

	HRESULT ( STDMETHODCALLTYPE *ActivateTab )(
		__RPC__in ITaskbarList * This,
		/* [in] */ __RPC__in HWND hwnd);

	HRESULT ( STDMETHODCALLTYPE *SetActiveAlt )(
		__RPC__in ITaskbarList * This,
		/* [in] */ __RPC__in HWND hwnd);

	END_INTERFACE
} ITaskbarListVtbl;
```


