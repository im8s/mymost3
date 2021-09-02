package com.sk.weichat.ui.base;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.sk.weichat.R;

import java.util.List;


/**
 * Created by Administrator on 2017/6/21.
 */
public abstract class BaseGridFragment<VH extends RecyclerView.ViewHolder> extends EasyFragment {


    public LayoutInflater mInflater;
    public PreviewAdapter mAdapter;
    RecyclerView mRecyclerView;
    SwipeRefreshLayout mSSRlayout;
    private int pager;
    private boolean loading = true;

    @Override
    protected int inflateLayoutId() {
        return R.layout.nearby_grid_fragment;
    }

    @Override
    protected void onActivityCreated(Bundle savedInstanceState, boolean createView) {
        if (createView) {
            Log.e("zx", "onActivityCreated: ");
            initView();
        }
    }

    private void initView() {
        mRecyclerView = (RecyclerView) findViewById(R.id.fragment_list_recyview);
        mSSRlayout = (SwipeRefreshLayout) findViewById(R.id.fragment_list_swip);
        mInflater = LayoutInflater.from(getActivity());

        mSSRlayout.setColorSchemeResources(R.color.text_select, R.color.dialog_normal,
                R.color.color_violet);

        mSSRlayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                pager = 0;
                initDatas(pager);
                loading = false;
            }
        });
//        RecyclerView.LayoutManager layoutManager = new GridLayoutManager(getActivity(), 2);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(getActivity());
        mRecyclerView.setLayoutManager(layoutManager);
        mAdapter = new PreviewAdapter();
        mRecyclerView.setAdapter(mAdapter);
        mRecyclerView.addOnScrollListener(new EndlessRecyclerOnScrollListener());
        initDatas(0);
        pager = 0;
    }

    /**
     * 数据层面
     */
    public abstract void initDatas(int pager);

    /* 视图层面 */
    public abstract VH initHolder(ViewGroup parent);

    public abstract void fillData(VH holder, int position);

    /**
     * 通知更新
     */
    public void update(List<?> data) {
        if (mSSRlayout.isRefreshing()) {
            Log.e("zx", "update: ");
            mSSRlayout.setRefreshing(false);
        }
        Log.e("zx", "update: noRefresh");
        mAdapter.setData(data);
    }

    class PreviewAdapter extends RecyclerView.Adapter<VH> {

        private List<?> data;

        @Override
        public VH onCreateViewHolder(ViewGroup parent, int viewType) {
            return initHolder(parent);
        }

        @Override
        public void onBindViewHolder(VH holder, int position) {
            fillData(holder, position);
        }

        @Override
        public int getItemCount() {
            if (data != null) {
                return data.size();
            }
            return 0;
        }

        public void setData(List<?> data) {
            if (data != null) {
                this.data = data;
                notifyDataSetChanged();
            }
        }
    }

    public class EndlessRecyclerOnScrollListener extends
            RecyclerView.OnScrollListener {
        int firstVisibleItem, visibleItemCount, totalItemCount, layoutManagerType = -1;
        private int previousTotal = 0;

        public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
            super.onScrolled(recyclerView, dx, dy);

            RecyclerView.LayoutManager layoutManager = recyclerView.getLayoutManager();
            if (layoutManager instanceof LinearLayoutManager) {
                firstVisibleItem = ((LinearLayoutManager) layoutManager).findLastVisibleItemPosition();
            } else if (layoutManager instanceof GridLayoutManager) {
                firstVisibleItem = ((GridLayoutManager) layoutManager).findLastVisibleItemPosition();
            } else {
                throw new RuntimeException(
                        "Unsupported LayoutManager used. Valid ones are LinearLayoutManager, GridLayoutManager and StaggeredGridLayoutManager");
            }
            visibleItemCount = recyclerView.getChildCount();
            totalItemCount = layoutManager.getItemCount();

            if (loading) {
                if (totalItemCount > previousTotal) {
                    loading = false;
                    previousTotal = totalItemCount;
                }
            }

            if (!loading && (totalItemCount - visibleItemCount) <= firstVisibleItem) {
                loading = true;
                pager++;
                initDatas(pager);
            }
        }
    }
}
