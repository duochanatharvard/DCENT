function r = rank(A,tol)

    disp(' ')
    disp('*****************************************************')
    disp('I am here, using the custmized function!')
    disp('*****************************************************')
    disp(' ')
    % Note that we know that the design matrix, X, should be "full" rank
    % i.e., rank = number of columns by construction of the design matrix

    if ~issparse(A)
        try
            s = svd(A);
        catch
            s = svds(A);
            disp('using svds because of sparse matrix...')
        end
        if nargin==1
           tol = max(size(A)) * eps(max(s));
        end
        r = sum(s > tol);
    else
        r = size(A,2);
    end
end
